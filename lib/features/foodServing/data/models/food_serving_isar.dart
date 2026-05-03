

import 'package:isar/isar.dart';
import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';

part 'food_serving_isar.g.dart';

@collection
class FoodServingIsar {

  Id id = Isar.autoIncrement;
  String label = "";
  String foodId = "";
  double servingSize = 0 ;

  FoodServing toEntity(){
    return FoodServing(
      id: id.toString(),
      foodId: foodId,
      label: label,
      servingSize: servingSize
    );
  }

  static FoodServingIsar fromEntity(FoodServing serving){
    return FoodServingIsar()
      ..id = int.parse(serving.id)
      ..foodId = serving.foodId
      ..label = serving.label
      ..servingSize = serving.servingSize;
  }
}