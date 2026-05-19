import 'package:macro_diary/features/meal/domain/entities/meal.dart';

abstract class MealRepository {
  Future<List<Meal>> getAllMeals();
  Future<Meal?> getMealById(String mealId);

  Future<Meal> addMeal(Meal meal);
  Future<Meal> updateMeal(Meal meal);
  Future<void> deleteMeal(String mealId);
}
