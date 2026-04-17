import 'package:isar/isar.dart';
import 'package:macro_diary/features/food/data/models/food_isar.dart';

class FoodLocalService {
  final Isar isar;

  FoodLocalService(this.isar);

  Future<void> addFood(FoodIsar food) async {
    await isar.writeTxn(() async {
      await isar.foodIsars.put(food);
    });
  }

  Future<void> deleteFood(int id) async {
    await isar.writeTxn(() async {
      await isar.foodIsars.delete(id);
    });
  }

  Future<List<FoodIsar>> getAllFoods() async {
    return await isar.foodIsars.where().findAll();
  }

  Future<FoodIsar?> getFoodById(int id) async {
    return await isar.foodIsars.get(id);
  }
}