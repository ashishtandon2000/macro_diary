import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/food/presentation/view_model/food_listing_viewmodel.dart';
import 'package:macro_diary/features/foodServing/data/repositories/food_serving_repository_impl.dart';
import 'package:macro_diary/features/foodServing/domain/repositories/food_serving_repository.dart';

import '../../domain/entities/food_serving.dart';

class ServingListingNotifier extends AsyncNotifier<List<FoodServing>> {
  FoodServingRepository get _servingRepo => ref.read(servingRepositoryProvider);
  Map<String, Food> _foodsMap = {};
  Map<String, Food> get foodsMap => _foodsMap;

  @override
  Future<List<FoodServing>> build() async {
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

    final servings = await _servingRepo.getAllServings();
    return servings
        .where((serving) => serving.hasAvailableFoods(_foodsMap))
        .toList();
  }

  Food? getFoodById(String id) {
    return _foodsMap[id];
  }

  Future<void> deleteServing(String servingId) async {
    await _servingRepo.deleteServing(servingId);
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.where((s) => s.id != servingId).toList());
    }
  }
}

final servingListingProvider =
    AsyncNotifierProvider<ServingListingNotifier, List<FoodServing>>(
        ServingListingNotifier.new);
