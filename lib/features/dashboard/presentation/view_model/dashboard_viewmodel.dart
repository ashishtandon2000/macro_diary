import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/food/data/repositories/food_repository_impl.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/food/domain/repositories/food_repository.dart';
import 'package:macro_diary/features/foodServing/data/repositories/food_serving_repository_impl.dart';
import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';
import 'package:macro_diary/features/foodServing/domain/repositories/food_serving_repository.dart';

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
  FoodServingRepository get _servingRepository =>
      ref.read(servingRepositoryProvider);

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
    final servingsFuture = _servingRepository.getAllServings();

    final foods = await foodsFuture;
    final servings = await servingsFuture;
    final foodMap = {for (final food in foods) food.id: food};
    final validServings = servings
        .where((serving) => serving.hasAvailableFoods(foodMap))
        .toList();

    return DashboardState(
      summary: summary ?? _emptyMacros,
      history: history ?? const [],
      foods: foods,
      servings: validServings,
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

  bool updateUsingFoodServing(FoodServing serving) {
    final current = state.value;
    if (current == null) return false;

    if (!serving.hasAvailableFoods(current.foodMap)) return false;

    updateUsingMacros(serving.getMacros(current.foodMap));
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

  Future<void> deleteServing(String servingId) async {
    await _servingRepository.deleteServing(servingId);

    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        servings: current.servings
            .where((serving) => serving.id != servingId)
            .toList(),
      ),
    );
  }

  Future<void> deleteFood(String foodId) async {
    await _foodRepository.deleteFood(foodId);

    final current = state.value;
    if (current == null) return;

    final foods = current.foods.where((food) => food.id != foodId).toList();
    final servings = current.servings
        .where((serving) => !serving.containsFood(foodId))
        .toList();
    state = AsyncData(
      current.copyWith(
        foods: foods,
        servings: servings,
        foodMap: {for (final food in foods) food.id: food},
      ),
    );
  }
}

class DashboardState {
  final Macros summary;
  final List<Macros> history;
  final List<Food> foods;
  final List<FoodServing> servings;
  final Map<String, Food> foodMap;

  const DashboardState({
    this.summary = _emptyMacros,
    this.history = const [],
    this.foods = const [],
    this.servings = const [],
    this.foodMap = const {},
  });

  bool get showRevertIcon => history.isNotEmpty;

  Food? getFoodById(String id) => foodMap[id];

  DashboardState copyWith({
    Macros? summary,
    List<Macros>? history,
    List<Food>? foods,
    List<FoodServing>? servings,
    Map<String, Food>? foodMap,
  }) {
    return DashboardState(
      summary: summary ?? this.summary,
      history: history ?? this.history,
      foods: foods ?? this.foods,
      servings: servings ?? this.servings,
      foodMap: foodMap ?? this.foodMap,
    );
  }
}
