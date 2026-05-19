import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/errors/exceptions.dart';
import 'package:macro_diary/core/errors/failures.dart';
import 'package:macro_diary/features/meal/data/models/meal_isar.dart';
import 'package:macro_diary/features/meal/data/services/meal_local_service.dart';
import 'package:macro_diary/features/meal/domain/entities/meal.dart';
import 'package:macro_diary/features/meal/domain/repositories/meal_repository.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  final service = ref.read(mealLocalServiceProvider);
  return MealRepositoryImpl(mealLocalService: service);
});

class MealRepositoryImpl extends MealRepository {
  MealLocalService mealLocalService;

  MealRepositoryImpl({required this.mealLocalService});

  @override
  Future<Meal> addMeal(Meal meal) async {
    try {
      final model = MealIsar.fromEntity(meal);
      final id = await mealLocalService.addMeal(model);
      model.id = id;
      return model.toEntity();
    } catch (_) {
      throw const CacheFailure("Failed to save meal");
    }
  }

  @override
  Future<Meal> updateMeal(Meal meal) async {
    try {
      final model = MealIsar.fromEntityWithId(meal);
      await mealLocalService.addMeal(model);
      return model.toEntity();
    } catch (_) {
      throw const CacheFailure("Failed to update meal");
    }
  }

  @override
  Future<void> deleteMeal(String mealId) async {
    try {
      await mealLocalService.deleteMeal(int.parse(mealId));
    } catch (_) {
      throw const CacheFailure("Failed to delete meal");
    }
  }

  @override
  Future<Meal?> getMealById(String mealId) async {
    try {
      final meal = await mealLocalService.getMealById(int.parse(mealId));
      return meal?.toEntity();
    } catch (_) {
      throw const CacheFailure("Failed to fetch meal");
    }
  }

  @override
  Future<List<Meal>> getAllMeals() async {
    try {
      final meals = await mealLocalService.getAllMeals();
      return meals.map((s) => s.toEntity()).toList();
    } on ParsingException {
      throw const ServerFailure("Invalid data from server");
    } on ServerException {
      throw const ServerFailure("Failed to fetch meals");
    } catch (_) {
      throw const CacheFailure("Failed to fetch meals");
    }
  }
}
