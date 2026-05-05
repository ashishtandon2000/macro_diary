
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/errors/exceptions.dart';
import 'package:macro_diary/core/errors/failures.dart';
import 'package:macro_diary/features/foodServing/data/models/food_serving_isar.dart';
import 'package:macro_diary/features/foodServing/data/services/food_serving_local_service.dart';
import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';
import 'package:macro_diary/features/foodServing/domain/repositories/food_serving_repository.dart';



final foodServingRepositoryImplProvider = Provider<FoodServingRepository>((ref){
  final service = ref.read(foodServingLocalServiceProvider);
  return FoodServingRepositoryImpl(
    servingLocalService: service
  );
});

class FoodServingRepositoryImpl extends FoodServingRepository{

  FoodServingLocalService servingLocalService;

  FoodServingRepositoryImpl({required this.servingLocalService});

  @override
  Future<void> addServing(FoodServing serving) async{
    try{
      final model = FoodServingIsar.fromEntity(serving);
      await servingLocalService.addServing(model);
    }catch(_){
      throw const CacheFailure("Failed to save serving");
    }
  }

  @override
  Future<void> updateServing(FoodServing serving) async{
    try{
      final model = FoodServingIsar.fromEntityWithId(serving);
      await servingLocalService.addServing(model);
    }catch(_){
      throw const CacheFailure("Failed to update serving");
    }
  }

  @override
  Future<void> deleteServing(String servingId) async{
    try{
      await servingLocalService.deleteServing(int.parse(servingId));
    }catch(_){
      throw const CacheFailure("Failed to delete serving");
    }
  }

  @override
  Future<FoodServing?> getServingById(String servingId) async{
    try{
      final serving = await servingLocalService.getServingById(int.parse(servingId));
      return serving?.toEntity();
    }catch(_){
      throw const CacheFailure("Failed to fetch serving");
    }
  }

  @override
  Future<List<FoodServing>> getAllServings() async {
    try{
      final servings = await servingLocalService.getAllServings();
      return servings.map((s)=>s.toEntity()).toList();
    } on ParsingException {
      throw const ServerFailure("Invalid data from server");
    } on ServerException {
      throw const ServerFailure("Failed to fetch servings");
    }
  }
}