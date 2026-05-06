

import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';

abstract class FoodServingRepository {

  Future<List<FoodServing>> getAllServings();
  Future<FoodServing?> getServingById(String servingId);

  Future<void> addServing(FoodServing serving);
  Future<void> updateServing(FoodServing serving);
  Future<void> deleteServing(String servingId);
}