import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/diary/data/models/diary_entry_isar.dart';
import 'package:macro_diary/features/diary/domain/entities/diary_entry.dart';
import 'package:macro_diary/features/food/data/models/food_isar.dart';
import 'package:macro_diary/features/food/data/services/food_local_service.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/meal/data/models/meal_isar.dart';
import 'package:macro_diary/features/meal/domain/entities/meal.dart';
import 'package:macro_diary/features/user_data/data/models/user_profile_isar.dart';

const _backupFormat = "macro_diary_backup";
const _backupVersion = 1;

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(isar: ref.read(isarProvider));
});

enum BackupSection { foods, meals, diary, userData }

extension BackupSectionInfo on BackupSection {
  String get key {
    switch (this) {
      case BackupSection.foods:
        return "foods";
      case BackupSection.meals:
        return "meals";
      case BackupSection.diary:
        return "diary";
      case BackupSection.userData:
        return "userData";
    }
  }

  String get label {
    switch (this) {
      case BackupSection.foods:
        return "Food items";
      case BackupSection.meals:
        return "Meals";
      case BackupSection.diary:
        return "Diary";
      case BackupSection.userData:
        return "User data";
    }
  }

  static BackupSection? fromKey(String key) {
    for (final section in BackupSection.values) {
      if (section.key == key) return section;
    }
    return null;
  }
}

class BackupException implements Exception {
  final String message;

  const BackupException(this.message);

  @override
  String toString() => message;
}

class BackupPreview {
  final DateTime? exportedAt;
  final Set<BackupSection> availableSections;
  final Map<BackupSection, int> counts;

  const BackupPreview({
    required this.exportedAt,
    required this.availableSections,
    required this.counts,
  });

  int countFor(BackupSection section) => counts[section] ?? 0;
}

class BackupImportResult {
  final Map<BackupSection, int> importedCounts;
  final Map<BackupSection, int> skippedCounts;

  const BackupImportResult({
    required this.importedCounts,
    required this.skippedCounts,
  });

  int importedFor(BackupSection section) => importedCounts[section] ?? 0;

  int skippedFor(BackupSection section) => skippedCounts[section] ?? 0;
}

class BackupService {
  final Isar isar;

  const BackupService({required this.isar});

  Future<String> createBackupJson(Set<BackupSection> sections) async {
    _validateSections(sections);

    final data = <String, dynamic>{};
    if (sections.contains(BackupSection.foods)) {
      final foods = await isar.foodIsars.where().findAll();
      data[BackupSection.foods.key] =
          foods.map((food) => _foodToJson(food.toEntity())).toList();
    }

    if (sections.contains(BackupSection.meals)) {
      final meals = await isar.mealIsars.where().findAll();
      data[BackupSection.meals.key] =
          meals.map((meal) => _mealToJson(meal.toEntity())).toList();
    }

    if (sections.contains(BackupSection.diary)) {
      final entries = await isar.diaryEntryIsars.where().findAll();
      data[BackupSection.diary.key] =
          entries.map((entry) => _diaryEntryToJson(entry.toEntity())).toList();
    }

    if (sections.contains(BackupSection.userData)) {
      final profile = await isar.userProfileIsars.get(1);
      data[BackupSection.userData.key] =
          profile == null ? null : _userProfileToJson(profile);
    }

    return const JsonEncoder.withIndent("  ").convert(
      {
        "format": _backupFormat,
        "version": _backupVersion,
        "exportedAt": DateTime.now().toIso8601String(),
        "sections": sections.map((section) => section.key).toList(),
        "data": data,
      },
    );
  }

  BackupPreview previewBackup(String backupJson) {
    final backup = _decodeBackup(backupJson);
    final data = _asMap(backup["data"]);
    final availableSections = <BackupSection>{};
    final counts = <BackupSection, int>{};

    final foods = _asList(data[BackupSection.foods.key]);
    if (foods.isNotEmpty) {
      availableSections.add(BackupSection.foods);
      counts[BackupSection.foods] = foods.length;
    }

    final meals = _asList(data[BackupSection.meals.key]);
    if (meals.isNotEmpty) {
      availableSections.add(BackupSection.meals);
      counts[BackupSection.meals] = meals.length;
    }

    final diary = _asList(data[BackupSection.diary.key]);
    if (diary.isNotEmpty) {
      availableSections.add(BackupSection.diary);
      counts[BackupSection.diary] = diary.length;
    }

    if (data[BackupSection.userData.key] is Map) {
      availableSections.add(BackupSection.userData);
      counts[BackupSection.userData] = 1;
    }

    return BackupPreview(
      exportedAt: DateTime.tryParse(_stringValue(backup["exportedAt"])),
      availableSections: availableSections,
      counts: counts,
    );
  }

  Future<BackupImportResult> importBackupJson(
    String backupJson,
    Set<BackupSection> sections,
  ) async {
    _validateSections(sections);

    final backup = _decodeBackup(backupJson);
    final data = _asMap(backup["data"]);
    final selected = sections.where((section) {
      return _hasSectionData(data, section);
    }).toSet();

    final imported = {
      for (final section in BackupSection.values) section: 0,
    };
    final skipped = {
      for (final section in BackupSection.values) section: 0,
    };

    final foodIdMap = <String, String>{};
    final mealIdMap = <String, String>{};

    final existingFoods = await isar.foodIsars.where().findAll();
    final existingFoodByKey = {
      for (final food in existingFoods.map((food) => food.toEntity()))
        _foodDuplicateKey(food): food,
    };

    final existingMeals = await isar.mealIsars.where().findAll();
    final existingMealByKey = {
      for (final meal in existingMeals.map((meal) => meal.toEntity()))
        _mealDuplicateKey(meal): meal,
    };

    final existingDiary = await isar.diaryEntryIsars.where().findAll();
    final existingDiaryKeys = existingDiary
        .map((entry) => _diaryDuplicateKey(entry.toEntity()))
        .toSet();

    await isar.writeTxn(() async {
      if (selected.contains(BackupSection.foods)) {
        for (final item in _asList(data[BackupSection.foods.key])) {
          final food = _foodFromJson(_asMap(item));
          if (food == null) {
            skipped[BackupSection.foods] =
                skippedFor(skipped, BackupSection.foods) + 1;
            continue;
          }

          final duplicate = existingFoodByKey[_foodDuplicateKey(food)];
          if (duplicate != null) {
            foodIdMap[food.id] = duplicate.id;
            skipped[BackupSection.foods] =
                skippedFor(skipped, BackupSection.foods) + 1;
            continue;
          }

          final model = FoodIsar.fromEntity(food);
          final id = await isar.foodIsars.put(model);
          final savedFood = food.copyWith(id: id.toString());
          foodIdMap[food.id] = savedFood.id;
          existingFoodByKey[_foodDuplicateKey(savedFood)] = savedFood;
          imported[BackupSection.foods] =
              importedFor(imported, BackupSection.foods) + 1;
        }
      }

      if (selected.contains(BackupSection.meals)) {
        for (final item in _asList(data[BackupSection.meals.key])) {
          final meal = _mealFromJson(_asMap(item), foodIdMap);
          if (meal == null) {
            skipped[BackupSection.meals] =
                skippedFor(skipped, BackupSection.meals) + 1;
            continue;
          }

          final key = _mealDuplicateKey(meal);
          final duplicate = existingMealByKey[key];
          if (duplicate != null) {
            mealIdMap[meal.id] = duplicate.id;
            skipped[BackupSection.meals] =
                skippedFor(skipped, BackupSection.meals) + 1;
            continue;
          }

          final model = MealIsar.fromEntity(meal);
          final id = await isar.mealIsars.put(model);
          final savedMeal = meal.copyWith(id: id.toString());
          mealIdMap[meal.id] = savedMeal.id;
          existingMealByKey[key] = savedMeal;
          imported[BackupSection.meals] =
              importedFor(imported, BackupSection.meals) + 1;
        }
      }

      if (selected.contains(BackupSection.diary)) {
        for (final item in _asList(data[BackupSection.diary.key])) {
          final entry = _diaryEntryFromJson(
            _asMap(item),
            foodIdMap: foodIdMap,
            mealIdMap: mealIdMap,
          );
          if (entry == null) {
            skipped[BackupSection.diary] =
                skippedFor(skipped, BackupSection.diary) + 1;
            continue;
          }

          final key = _diaryDuplicateKey(entry);
          if (existingDiaryKeys.contains(key)) {
            skipped[BackupSection.diary] =
                skippedFor(skipped, BackupSection.diary) + 1;
            continue;
          }

          await isar.diaryEntryIsars.put(DiaryEntryIsar.fromEntity(entry));
          existingDiaryKeys.add(key);
          imported[BackupSection.diary] =
              importedFor(imported, BackupSection.diary) + 1;
        }
      }

      if (selected.contains(BackupSection.userData)) {
        final profileJson = _asMap(data[BackupSection.userData.key]);
        final profile = _userProfileFromJson(profileJson);
        await isar.userProfileIsars.put(profile);
        imported[BackupSection.userData] = 1;
      }
    });

    return BackupImportResult(
      importedCounts: imported,
      skippedCounts: skipped,
    );
  }

  int importedFor(Map<BackupSection, int> counts, BackupSection section) {
    return counts[section] ?? 0;
  }

  int skippedFor(Map<BackupSection, int> counts, BackupSection section) {
    return counts[section] ?? 0;
  }

  void _validateSections(Set<BackupSection> sections) {
    if (sections.isEmpty) {
      throw const BackupException("Select at least one backup section.");
    }
    if (sections.contains(BackupSection.meals) &&
        !sections.contains(BackupSection.foods)) {
      throw const BackupException("Meals require food items in the backup.");
    }
  }

  bool _hasSectionData(Map<String, dynamic> data, BackupSection section) {
    if (section == BackupSection.userData) {
      return data[section.key] is Map;
    }
    return _asList(data[section.key]).isNotEmpty;
  }

  Map<String, dynamic> _decodeBackup(String backupJson) {
    final decoded = jsonDecode(backupJson);
    if (decoded is! Map) {
      throw const BackupException("Invalid backup file.");
    }

    final backup = _asMap(decoded);
    if (backup["format"] != _backupFormat) {
      throw const BackupException("This is not a Macro Diary backup file.");
    }
    if (_intValue(backup["version"]) != _backupVersion) {
      throw const BackupException("Unsupported backup version.");
    }
    return backup;
  }

  Map<String, dynamic> _foodToJson(Food food) {
    return {
      "id": food.id,
      "externalId": food.externalId,
      "name": food.name,
      "unit": food.unit.name,
      "macros": _macrosToJson(food.macros),
    };
  }

  Food? _foodFromJson(Map<String, dynamic> json) {
    final id = _stringValue(json["id"]);
    final name = _stringValue(json["name"]).trim();
    if (id.isEmpty || name.isEmpty) return null;

    return Food(
      id: id,
      externalId: _nullableString(json["externalId"]),
      name: name,
      unit: _measureUnitFromString(_stringValue(json["unit"])),
      macros: _macrosFromJson(json["macros"]),
    );
  }

  Map<String, dynamic> _mealToJson(Meal meal) {
    return {
      "id": meal.id,
      "label": meal.label,
      "items": meal.items
          .map(
            (item) => {
              "foodId": item.foodId,
              "amount": item.amount,
            },
          )
          .toList(),
    };
  }

  Meal? _mealFromJson(
    Map<String, dynamic> json,
    Map<String, String> foodIdMap,
  ) {
    final id = _stringValue(json["id"]);
    final label = _stringValue(json["label"]).trim();
    if (id.isEmpty || label.isEmpty) return null;

    final items = <MealItem>[];
    for (final item in _asList(json["items"])) {
      final itemJson = _asMap(item);
      final oldFoodId = _stringValue(itemJson["foodId"]);
      final newFoodId = foodIdMap[oldFoodId];
      final amount = _doubleValue(itemJson["amount"]);
      if (newFoodId == null || amount <= 0 || !amount.isFinite) return null;
      items.add(MealItem(foodId: newFoodId, amount: amount));
    }

    if (items.isEmpty) return null;
    return Meal(id: id, label: label, items: items);
  }

  Map<String, dynamic> _diaryEntryToJson(DiaryEntry entry) {
    return {
      "id": entry.id,
      "type": entry.type.name,
      "title": entry.title,
      "sourceId": entry.sourceId,
      "consumedAt": entry.consumedAt.toIso8601String(),
      "details": entry.details,
      "macros": _macrosToJson(entry.macros),
    };
  }

  DiaryEntry? _diaryEntryFromJson(
    Map<String, dynamic> json, {
    required Map<String, String> foodIdMap,
    required Map<String, String> mealIdMap,
  }) {
    final title = _stringValue(json["title"]).trim();
    if (title.isEmpty) return null;

    final type = _diaryEntryTypeFromString(_stringValue(json["type"]));
    final sourceId = _remapSourceId(
      type: type,
      sourceId: _nullableString(json["sourceId"]),
      foodIdMap: foodIdMap,
      mealIdMap: mealIdMap,
    );

    return DiaryEntry(
      id: "",
      type: type,
      title: title,
      sourceId: sourceId,
      consumedAt:
          DateTime.tryParse(_stringValue(json["consumedAt"])) ?? DateTime.now(),
      details: _asList(json["details"]).map((item) => item.toString()).toList(),
      macros: _macrosFromJson(json["macros"]),
    );
  }

  Map<String, dynamic> _userProfileToJson(UserProfileIsar profile) {
    return {
      "name": profile.name,
      "gender": profile.gender,
      "age": profile.age,
      "heightCm": profile.heightCm,
      "weightKg": profile.weightKg,
      "activityLevel": profile.activityLevel,
      "goalType": profile.goalType,
      "targetCalories": profile.targetCalories,
      "targetProtein": profile.targetProtein,
      "targetCarbs": profile.targetCarbs,
      "targetFats": profile.targetFats,
      "bmr": profile.bmr,
      "tdee": profile.tdee,
      "hasCompletedGuide": profile.hasCompletedGuide,
      "personalDetailsUpdatedAt":
          profile.personalDetailsUpdatedAt?.toIso8601String(),
      "targetUpdatedAt": profile.targetUpdatedAt?.toIso8601String(),
      "updatedAt": profile.updatedAt.toIso8601String(),
    };
  }

  UserProfileIsar _userProfileFromJson(Map<String, dynamic> json) {
    return UserProfileIsar()
      ..id = 1
      ..name = _stringValue(json["name"])
      ..gender = _stringValue(json["gender"])
      ..age = _nullableInt(json["age"])
      ..heightCm = _nullableDouble(json["heightCm"])
      ..weightKg = _nullableDouble(json["weightKg"])
      ..activityLevel = _stringValue(json["activityLevel"])
      ..goalType = _stringValue(json["goalType"])
      ..targetCalories = _doubleValue(json["targetCalories"])
      ..targetProtein = _doubleValue(json["targetProtein"])
      ..targetCarbs = _doubleValue(json["targetCarbs"])
      ..targetFats = _doubleValue(json["targetFats"])
      ..bmr = _nullableDouble(json["bmr"])
      ..tdee = _nullableDouble(json["tdee"])
      ..hasCompletedGuide = json["hasCompletedGuide"] == true
      ..personalDetailsUpdatedAt =
          DateTime.tryParse(_stringValue(json["personalDetailsUpdatedAt"]))
      ..targetUpdatedAt =
          DateTime.tryParse(_stringValue(json["targetUpdatedAt"]))
      ..updatedAt =
          DateTime.tryParse(_stringValue(json["updatedAt"])) ?? DateTime.now();
  }

  Map<String, dynamic> _macrosToJson(Macros macros) {
    return {
      "calories": macros.calories,
      "protein": macros.protein,
      "carbs": macros.carbs,
      "fats": macros.fats,
    };
  }

  Macros _macrosFromJson(Object? value) {
    final json = _asMap(value);
    return Macros(
      calories: _doubleValue(json["calories"]),
      protein: _doubleValue(json["protein"]),
      carbs: _doubleValue(json["carbs"]),
      fats: _doubleValue(json["fats"]),
    );
  }

  String? _remapSourceId({
    required DiaryEntryType type,
    required String? sourceId,
    required Map<String, String> foodIdMap,
    required Map<String, String> mealIdMap,
  }) {
    if (sourceId == null || sourceId.isEmpty) return null;
    switch (type) {
      case DiaryEntryType.custom:
        return null;
      case DiaryEntryType.food:
        return foodIdMap[sourceId];
      case DiaryEntryType.meal:
        final mappedId = mealIdMap[sourceId];
        return mappedId == null || mappedId.isEmpty ? null : mappedId;
    }
  }

  String _foodDuplicateKey(Food food) {
    final externalId = food.externalId?.trim().toLowerCase();
    if (externalId != null && externalId.isNotEmpty) {
      return "external:$externalId";
    }

    return [
      "manual",
      food.name.trim().toLowerCase(),
      food.unit.name,
      food.macros.calories.toStringAsFixed(4),
      food.macros.protein.toStringAsFixed(4),
      food.macros.carbs.toStringAsFixed(4),
      food.macros.fats.toStringAsFixed(4),
    ].join("|");
  }

  String _mealDuplicateKey(Meal meal) {
    final items = meal.items
        .map((item) => "${item.foodId}:${item.amount.toStringAsFixed(4)}")
        .toList()
      ..sort();
    return "${meal.label.trim().toLowerCase()}|${items.join(",")}";
  }

  String _diaryDuplicateKey(DiaryEntry entry) {
    return [
      entry.type.name,
      entry.title.trim().toLowerCase(),
      entry.consumedAt.toIso8601String(),
      entry.macros.calories.toStringAsFixed(4),
      entry.macros.protein.toStringAsFixed(4),
      entry.macros.carbs.toStringAsFixed(4),
      entry.macros.fats.toStringAsFixed(4),
      entry.details.join("|"),
    ].join("|");
  }

  MeasureUnit _measureUnitFromString(String value) {
    return MeasureUnit.values.firstWhere(
      (unit) => unit.name == value,
      orElse: () => MeasureUnit.gram,
    );
  }

  DiaryEntryType _diaryEntryTypeFromString(String value) {
    return DiaryEntryType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => DiaryEntryType.custom,
    );
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is! Map) return {};
    return value.map((key, value) => MapEntry(key.toString(), value));
  }

  List<Object?> _asList(Object? value) {
    if (value is! List) return const [];
    return value;
  }

  String _stringValue(Object? value) => value?.toString() ?? "";

  String? _nullableString(Object? value) {
    final string = _stringValue(value).trim();
    return string.isEmpty ? null : string;
  }

  int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(_stringValue(value)) ?? 0;
  }

  int? _nullableInt(Object? value) {
    if (value == null) return null;
    return _intValue(value);
  }

  double _doubleValue(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(_stringValue(value)) ?? 0;
  }

  double? _nullableDouble(Object? value) {
    if (value == null) return null;
    return _doubleValue(value);
  }
}
