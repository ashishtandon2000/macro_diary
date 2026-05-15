import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';

abstract class FoodServingRepository {
  Future<List<FoodServing>> getAllServings();
  Future<FoodServing?> getServingById(String servingId);

  Future<FoodServing> addServing(FoodServing serving);
  Future<FoodServing> updateServing(FoodServing serving);
  Future<void> deleteServing(String servingId);
}
