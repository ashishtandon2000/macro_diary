import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:macro_diary/features/food/data/models/food_isar.dart';

final _isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError();
});

final foodLocalServiceProvider = Provider<FoodLocalService>((ref) {
  final isar = ref.watch(_isarProvider);
  return FoodLocalService(isar);
});


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