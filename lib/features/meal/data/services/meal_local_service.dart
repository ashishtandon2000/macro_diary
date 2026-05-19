import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:macro_diary/features/food/data/services/food_local_service.dart';
import 'package:macro_diary/features/meal/data/models/meal_isar.dart';

final mealLocalServiceProvider = Provider<MealLocalService>((ref) {
  final isar = ref.read(isarProvider);
  return MealLocalService(isar: isar);
});

class MealLocalService {
  final Isar isar;

  MealLocalService({required this.isar});

  Future<int> addMeal(MealIsar meal) async {
    return await isar.writeTxn(() async {
      return await isar.mealIsars.put(meal);
    });
  }

  Future<void> deleteMeal(int id) async {
    await isar.writeTxn(() async {
      await isar.mealIsars.delete(id);
    });
  }

  Future<List<MealIsar>> getAllMeals() async {
    return await isar.mealIsars.where().findAll();
  }

  Future<MealIsar?> getMealById(int id) async {
    return await isar.mealIsars.get(id);
  }
}
