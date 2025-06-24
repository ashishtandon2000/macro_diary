import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/macros.dart';

class FoodServing {
  final String id;
  final String label;
  final String foodId;
  final int servingSize;

  const FoodServing({
    required this.id,
    required this.label,
    required this.foodId,
    required this.servingSize,
  });


  FoodServing copyWith({
    String? id,
    String? label,
    String? foodId,
    int? servingSize,
}){
    return FoodServing(
      id: id ?? this.id,
      label: label ?? this.label,
      foodId: foodId ?? this.foodId,
      servingSize: servingSize ?? this.servingSize,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'foodId': foodId,
    'servingSize': servingSize,
  };

  factory FoodServing.fromJson(Map<String, dynamic> json){
    return FoodServing(
        id: Util.fGetMapSafely<String>(data: json,key: "id"),
        label: Util.fGetMapSafely<String>(data: json,key: "label"),
        foodId: Util.fGetMapSafely<String>(data: json,key: "foodId"),
        servingSize: Util.fGetMapSafely<int>(data: json, key: "servingSize")
    );
  }

  @override
  String toString() {
    return 'FoodServing(id: $id, label: $label, foodId: $foodId, servingSize: $servingSize)';
  }

  // Get macros per serve for the food
  Macros getMacros(FoodItem food){

    double perUnitRatio = _unitRatio(food.unit);
    return Macros(
      calories: (food.macros.calories.toDouble() * perUnitRatio * servingSize.toDouble()).toInt(),
      carbs: _roundOff(food.macros.carbs * perUnitRatio * servingSize.toDouble()),
      protein: _roundOff(food.macros.protein * perUnitRatio * servingSize.toDouble()),
      fats: _roundOff(food.macros.fats * perUnitRatio * servingSize.toDouble()),
    );
  }

  double _roundOff(double value){
    double rounded = double.parse(value.toStringAsFixed(2));
    return rounded;
  }

  double _unitRatio(MeasureUnit unit) {
    switch (unit) {
      case MeasureUnit.gram:
        return 0.01;
      case MeasureUnit.milliliter:
        return 0.01;
      case MeasureUnit.piece:
      default:
        return 1.0;
    }
  }
}
