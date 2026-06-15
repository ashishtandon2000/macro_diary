import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/diary/data/repositories/diary_repository_impl.dart';
import 'package:macro_diary/features/diary/domain/entities/diary_entry.dart';
import 'package:macro_diary/features/diary/domain/repositories/diary_repository.dart';
import 'package:macro_diary/features/food/data/repositories/food_repository_impl.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/food/domain/repositories/food_repository.dart';
import 'package:macro_diary/features/meal/data/repositories/meal_repository_impl.dart';
import 'package:macro_diary/features/meal/domain/entities/meal.dart';
import 'package:macro_diary/features/meal/domain/repositories/meal_repository.dart';

const _emptyMacros = Macros(
  calories: 0,
  protein: 0,
  carbs: 0,
  fats: 0,
);

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardState>(
  DashboardNotifier.new,
);

class DashboardNotifier extends AsyncNotifier<DashboardState> {
  DiaryRepository get _diaryRepository => ref.read(diaryRepositoryProvider);
  FoodRepository get _foodRepository => ref.read(foodRepositoryProvider);
  MealRepository get _mealRepository => ref.read(mealRepositoryProvider);

  @override
  FutureOr<DashboardState> build() {
    return _loadDashboard();
  }

  Future<void> refresh() async {
    final current = state.value;
    state = const AsyncLoading();

    try {
      state = AsyncData(
        await _loadDashboard(
          preservedEntries: current?.history,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<DashboardState> _loadDashboard({
    List<DiaryEntry>? preservedEntries,
  }) async {
    final diaryFuture = preservedEntries == null
        ? _diaryRepository.getEntriesForDay(DateTime.now())
        : Future.value(preservedEntries);
    final foodsFuture = _foodRepository.getAllFoods();
    final mealsFuture = _mealRepository.getAllMeals();

    final entries = await diaryFuture;
    final foods = await foodsFuture;
    final meals = await mealsFuture;
    final foodMap = {for (final food in foods) food.id: food};
    final validMeals =
        meals.where((meal) => meal.hasAvailableFoods(foodMap)).toList();

    return DashboardState(
      summary: _sumEntries(entries),
      history: entries,
      foods: foods,
      meals: validMeals,
      foodMap: foodMap,
    );
  }

  Future<void> updateUsingMacros(Macros macros) async {
    await _addSummaryEntry(
      DiaryEntry(
        id: "",
        type: DiaryEntryType.custom,
        title: "Manually added",
        macros: macros,
        consumedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateUsingFood(Food food) async {
    await _addSummaryEntry(
      DiaryEntry(
        id: "",
        type: DiaryEntryType.food,
        title: food.name,
        macros: food.macros,
        consumedAt: DateTime.now(),
        sourceId: food.id,
      ),
    );
  }

  Future<bool> updateUsingMeal(Meal meal) async {
    final current = state.value;
    if (current == null) return false;

    if (!meal.hasAvailableFoods(current.foodMap)) return false;

    await _addSummaryEntry(
      DiaryEntry(
        id: "",
        type: DiaryEntryType.meal,
        title: meal.label,
        macros: meal.getMacros(current.foodMap),
        consumedAt: DateTime.now(),
        sourceId: meal.id,
        details: meal.items.map((item) {
          final food = current.foodMap[item.foodId]!;
          return "${food.name} - ${item.amount} ${food.unit.name}";
        }).toList(),
      ),
    );
    return true;
  }

  Future<void> revertLast() async {
    final current = state.value;
    if (current == null || current.history.isEmpty) return;

    final entry = current.history.last;
    await _diaryRepository.deleteEntry(entry.id);

    state = AsyncData(
      current.copyWith(
        summary: current.summary - entry.macros,
        history: current.history.sublist(0, current.history.length - 1),
      ),
    );
  }

  Future<void> resetSummary() async {
    final current = state.value;
    if (current == null) return;

    await _diaryRepository.deleteEntriesForDay(DateTime.now());

    state = AsyncData(
      current.copyWith(
        summary: _emptyMacros,
        history: const [],
      ),
    );
  }

  Future<void> removeSummaryEntry(int index) async {
    final current = state.value;
    if (current == null || index < 0 || index >= current.history.length) {
      return;
    }

    final entry = current.history[index];
    await _diaryRepository.deleteEntry(entry.id);

    final history = [...current.history]..removeAt(index);

    state = AsyncData(
      current.copyWith(
        summary: current.summary - entry.macros,
        history: history,
      ),
    );
  }

  Future<void> deleteMeal(String mealId) async {
    await _mealRepository.deleteMeal(mealId);

    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        meals: current.meals.where((meal) => meal.id != mealId).toList(),
      ),
    );
  }

  Future<void> deleteFood(String foodId) async {
    await _foodRepository.deleteFood(foodId);

    final current = state.value;
    if (current == null) return;

    final foods = current.foods.where((food) => food.id != foodId).toList();
    final meals =
        current.meals.where((meal) => !meal.containsFood(foodId)).toList();
    state = AsyncData(
      current.copyWith(
        foods: foods,
        meals: meals,
        foodMap: {for (final food in foods) food.id: food},
      ),
    );
  }

  Future<void> _addSummaryEntry(DiaryEntry entry) async {
    final current = state.value;
    if (current == null) return;

    final savedEntry = await _diaryRepository.addEntry(entry);

    state = AsyncData(
      current.copyWith(
        summary: current.summary + savedEntry.macros,
        history: [...current.history, savedEntry],
      ),
    );
  }

  Macros _sumEntries(List<DiaryEntry> entries) {
    var summary = _emptyMacros;
    for (final entry in entries) {
      summary += entry.macros;
    }
    return summary;
  }
}

class DashboardState {
  final Macros summary;
  final List<DiaryEntry> history;
  final List<Food> foods;
  final List<Meal> meals;
  final Map<String, Food> foodMap;

  const DashboardState({
    this.summary = _emptyMacros,
    this.history = const [],
    this.foods = const [],
    this.meals = const [],
    this.foodMap = const {},
  });

  bool get showRevertIcon => history.isNotEmpty;

  Food? getFoodById(String id) => foodMap[id];

  DashboardState copyWith({
    Macros? summary,
    List<DiaryEntry>? history,
    List<Food>? foods,
    List<Meal>? meals,
    Map<String, Food>? foodMap,
  }) {
    return DashboardState(
      summary: summary ?? this.summary,
      history: history ?? this.history,
      foods: foods ?? this.foods,
      meals: meals ?? this.meals,
      foodMap: foodMap ?? this.foodMap,
    );
  }
}
