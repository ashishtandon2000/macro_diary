import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';

class FoodServing {
  final String id;
  final String label;
  final String foodId;
  final double servingSize;

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
    double? servingSize,
  }) {
    return FoodServing(
      id: id ?? this.id,
      label: label ?? this.label,
      foodId: foodId ?? this.foodId,
      servingSize: servingSize ?? this.servingSize,
    );
  }

  @override
  String toString() {
    return 'FoodServing(id: $id, label: $label, foodId: $foodId, servingSize: $servingSize)';
  }

  /// Get macros per serve for the food
  Macros getMacros(Food food) {
    double perUnitRatio = _unitRatio(food.unit);
    return Macros(
      calories: food.macros.calories.toDouble() *
          perUnitRatio *
          servingSize.toDouble(),
      carbs: food.macros.carbs * perUnitRatio * servingSize.toDouble(),
      protein: food.macros.protein * perUnitRatio * servingSize.toDouble(),
      fats: food.macros.fats * perUnitRatio * servingSize.toDouble(),
    );
  }

  double _unitRatio(MeasureUnit unit) {
    switch (unit) {
      case MeasureUnit.gram:
        return 0.01;
      case MeasureUnit.milliliter:
        return 0.01;
      case MeasureUnit.piece:
        return 1.0;
    }
  }

// Map<String, dynamic> toJson() => {
//   'id': id,
//   'label': label,
//   'foodId': foodId,
//   'servingSize': servingSize,
// };
//
// factory FoodServing.fromJson(Map<String, dynamic> json){
//   return FoodServing(
//       id: Util.fGetMapSafely<String>(data: json,key: "id"),
//       label: Util.fGetMapSafely<String>(data: json,key: "label"),
//       foodId: Util.fGetMapSafely<String>(data: json,key: "foodId"),
//       servingSize: Util.fGetMapSafely<int>(data: json, key: "servingSize")
//   );
// }
//
}
