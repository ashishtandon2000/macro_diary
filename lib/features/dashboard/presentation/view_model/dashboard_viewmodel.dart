import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
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
          summary: current?.summary,
          history: current?.history,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<DashboardState> _loadDashboard({
    Macros? summary,
    List<Macros>? history,
  }) async {
    final foodsFuture = _foodRepository.getAllFoods();
    final mealsFuture = _mealRepository.getAllMeals();

    final foods = await foodsFuture;
    final meals = await mealsFuture;
    final foodMap = {for (final food in foods) food.id: food};
    final validMeals =
        meals.where((meal) => meal.hasAvailableFoods(foodMap)).toList();

    return DashboardState(
      summary: summary ?? _emptyMacros,
      history: history ?? const [],
      foods: foods,
      meals: validMeals,
      foodMap: foodMap,
    );
  }

  void updateUsingMacros(Macros macros) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        summary: current.summary + macros,
        history: [...current.history, macros],
      ),
    );
  }

  void updateUsingFood(Food food) {
    updateUsingMacros(food.macros);
  }

  bool updateUsingMeal(Meal meal) {
    final current = state.value;
    if (current == null) return false;

    if (!meal.hasAvailableFoods(current.foodMap)) return false;

    updateUsingMacros(meal.getMacros(current.foodMap));
    return true;
  }

  void revertLast() {
    final current = state.value;
    if (current == null || current.history.isEmpty) return;

    final lastMacros = current.history.last;
    state = AsyncData(
      current.copyWith(
        summary: current.summary - lastMacros,
        history: current.history.sublist(0, current.history.length - 1),
      ),
    );
  }

  void resetSummary() {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        summary: _emptyMacros,
        history: const [],
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
}

class DashboardState {
  final Macros summary;
  final List<Macros> history;
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
    List<Macros>? history,
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
