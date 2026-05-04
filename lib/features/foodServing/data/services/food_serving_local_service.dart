import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:macro_diary/features/food/data/services/food_local_service.dart';
import 'package:macro_diary/features/foodServing/data/models/food_serving_isar.dart';


final foodServingLocalServiceProvider = Provider<FoodServingLocalService>((ref){
  final isar = ref.read(isarProvider);
  return FoodServingLocalService(
    isar: isar
  );
});

class FoodServingLocalService {

  final Isar isar;

  FoodServingLocalService({required this.isar});

  Future<void> addServing(FoodServingIsar serving)async{
    await isar.writeTxn(()async{
      isar.foodServingIsars.put(serving);
    });
  }

  Future<void> deleteServing(int id)async{
      await isar.writeTxn(()async{
        isar.foodServingIsars.delete(id);
      });
  }

  Future<List<FoodServingIsar>> getAllServings()async{
    return await isar.foodServingIsars.where().findAll();
  }

  Future<FoodServingIsar?> getServingById(int id)async{
    return await isar.foodServingIsars.get(id);
  }
}