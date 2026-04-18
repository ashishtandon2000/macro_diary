


import 'package:macro_diary/core/errors/exceptions.dart';
import 'package:macro_diary/core/errors/failures.dart';
import 'package:macro_diary/features/food/data/models/food_isar.dart';
import 'package:macro_diary/features/food/data/services/food_local_service.dart';
import 'package:macro_diary/features/food/data/services/usda_api_service.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/food/domain/repositories/food_repository.dart';

class FoodRepositoryImpl implements FoodRepository{
  const FoodRepositoryImpl({required this.usdaService,required this.localService});

  final UsdaApiService usdaService;
  final FoodLocalService localService;


  @override
  Future<void> addFood(Food food) async{
    try {
      final model = FoodIsar.fromEntity(food);
      await localService.addFood(model);
    } catch (_) {
      throw const CacheFailure("Failed to save food");
    }
  }

  @override
  Future<void> updateFood(Food food) async{
    try{
      final model = FoodIsar.fromEntity(food)
      ..id = int.parse(food.id);

      await localService.addFood(model);
    }catch(_){
      throw const CacheFailure("Failed to update food");
    }
  }


  @override
  Future<void> deleteFood(String foodId) async{
    try{
     await localService.deleteFood(int.parse(foodId));
    }catch(_){
      throw const CacheFailure("Failed to delete food");
    }
  }




  @override
  Future<List<Food>> getAllFoods()async {
    try{
     final models = await localService.getAllFoods();
     return models.map((e)=>e.toEntity()).toList();
    }catch(_){
      throw const CacheFailure("Failed to fetch all foods");
    }
  }

  @override
  Future<Food?> getFoodById(String foodId) async {
    try {
      final model = await localService.getFoodById(int.parse(foodId));
      if (model == null) return null;
      return model.toEntity();
    } catch (_) {
      throw const CacheFailure("Failed to fetch food");
    }
  }

  // EXTERNAL API interactions
  @override
  Future<List<Food>> searchFoods(String query) async {
    try {
      final models = await usdaService.searchFoods(query);
      return models.map((e) => e.toEntity()).toList();
    } on ParsingException {
      throw const ServerFailure("Invalid data from server");
    } on ServerException {
      throw const ServerFailure("Failed to fetch foods");
    }
  }

  // @override
  // Future<Food> getFoodDetails(String externalId) {
  //   // TODO: implement getFoodDetails
  //   throw UnimplementedError();
  // }
}