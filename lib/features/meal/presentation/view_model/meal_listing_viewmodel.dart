import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/food/presentation/view_model/food_listing_viewmodel.dart';
import 'package:macro_diary/features/meal/data/repositories/meal_repository_impl.dart';
import 'package:macro_diary/features/meal/domain/repositories/meal_repository.dart';

import '../../domain/entities/meal.dart';

class MealListingNotifier extends AsyncNotifier<List<Meal>> {
  MealRepository get _mealRepo => ref.read(mealRepositoryProvider);
  Map<String, Food> _foodsMap = {};
  Map<String, Food> get foodsMap => _foodsMap;

  @override
  Future<List<Meal>> build() async {
    // ref.listen(
    //   foodListProvider,
    //       (_, next) {
    //     final foods = next.value ?? [];
    //     _foodsMap = {
    //       for(final food in foods) food.id : food
    //     };
    //   },
    // );

    final foods = await ref.watch(foodListProvider.future);
    _foodsMap = {for (final food in foods) food.id: food};

    final meals = await _mealRepo.getAllMeals();
    return meals.where((meal) => meal.hasAvailableFoods(_foodsMap)).toList();
  }

  Food? getFoodById(String id) {
    return _foodsMap[id];
  }

  Future<void> deleteMeal(String mealId) async {
    await _mealRepo.deleteMeal(mealId);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.where((s) => s.id != mealId).toList());
    }
  }
}

final mealListingProvider =
    AsyncNotifierProvider<MealListingNotifier, List<Meal>>(
        MealListingNotifier.new);
