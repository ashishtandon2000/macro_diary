import 'package:macro_diary/features/food/domain/entities/food.dart';

abstract class FoodRepository {
  // External Search
  Future<List<Food>> searchFoods(String query);
  Future<Food> getFoodDetails(String externalId);

  // Local CRUD
  Future<void> addFood(Food food);
  Future<void> updateFood(Food food);
  Future<void> deleteFood(String foodId);

  // Local queries
  Future<List<Food>> getAllFoods();
  Future<Food?> getFoodById(String foodId);
}
