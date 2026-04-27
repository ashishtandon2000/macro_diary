
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/features/food/data/repositories/food_repository_impl.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/food/domain/repositories/food_repository.dart';

// 1. Create Class that holds state
class FoodListingState{
  List<Food> foods;

  FoodListingState({required this.foods});

  FoodListingState copyWith({List<Food>? foods}){
    return FoodListingState(foods: foods??this.foods);
  }
}

// 2. Create Notifier that Manages state
class FoodListingNotifier extends AutoDisposeNotifier<FoodListingState>{

  FoodRepository get _repository => ref.read(foodRepositoryProvider);

  @override
  FoodListingState build() {
    return FoodListingState(foods: []);
  }

  Future deleteFood(String foodId)async{
    await _repository.deleteFood(foodId);

    final update = state.foods;
    update.removeWhere((food)=> food.id == foodId);
    state = state.copyWith(foods: update);
  }
}

// 3. Create a provider for notifier
// final foodListNotifier = NotifierProvider<FoodListingNotifier, FoodListingState>(FoodListingNotifier.new)
final foodListProvider = NotifierProvider.autoDispose<FoodListingNotifier, FoodListingState>(FoodListingNotifier.new);