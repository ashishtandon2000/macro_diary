
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/features/food/data/repositories/food_repository_impl.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/food/domain/repositories/food_repository.dart';


// 1. The Notifier manages a List<Food>
class FoodListingNotifier extends AsyncNotifier<List<Food>> {

  FoodRepository get _repository => ref.read(foodRepositoryProvider);

  @override
  Future<List<Food>> build() async {
    // This is your "InitState".
    // Riverpod calls this automatically when the provider is first used.
    return await _repository.getAllFoods();
  }

  Future<void> deleteFood(String foodId) async {
    // 1. Perform the async side effect
    await _repository.deleteFood(foodId);

    // 2. Update the state locally for an "Instant" UI update
    // 'state.value' gives you access to the current List<Food>
    final currentFoods = state.value ?? [];

    state = AsyncData(
      currentFoods.where((food) => food.id != foodId).toList(),
    );
  }
}

// 2. The Provider
final foodListProvider = AsyncNotifierProvider<FoodListingNotifier, List<Food>>(
  FoodListingNotifier.new,
);