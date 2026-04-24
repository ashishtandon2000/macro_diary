
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';

// 1. Create Class that holds state
class FoodListingState{
  List<Food> foods;

  FoodListingState({required this.foods});
}

// 2. Create Notifier that Manages state
class FoodListingNotifier extends AutoDisposeNotifier<FoodListingState>{

  @override
  FoodListingState build() {
    return FoodListingState(foods: []);
  }
}

// 3. Create a provider for notifier
// final foodListNotifier = NotifierProvider<FoodListingNotifier, FoodListingState>(FoodListingNotifier.new)
final foodListNotifier = NotifierProvider.autoDispose<FoodListingNotifier, FoodListingState>(FoodListingNotifier.new);