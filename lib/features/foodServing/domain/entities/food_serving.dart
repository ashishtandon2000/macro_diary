import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';

const _emptyMacros = Macros(calories: 0, protein: 0, carbs: 0, fats: 0);

class FoodServingItem {
  final String foodId;
  final double servingSize;

  const FoodServingItem({
    required this.foodId,
    required this.servingSize,
  });

  FoodServingItem copyWith({
    String? foodId,
    double? servingSize,
  }) {
    return FoodServingItem(
      foodId: foodId ?? this.foodId,
      servingSize: servingSize ?? this.servingSize,
    );
  }

  bool get isValid =>
      foodId.isNotEmpty && servingSize > 0 && servingSize.isFinite;

  @override
  String toString() {
    return 'FoodServingItem(foodId: $foodId, servingSize: $servingSize)';
  }
}

class FoodServing {
  final String id;
  final String label;
  final List<FoodServingItem> items;

  const FoodServing({
    required this.id,
    required this.label,
    required this.items,
  });

  String get foodId => items.isEmpty ? "" : items.first.foodId;
  double get servingSize => items.isEmpty ? 0 : items.first.servingSize;
  List<String> get foodIds => items.map((item) => item.foodId).toList();

  FoodServing copyWith({
    String? id,
    String? label,
    List<FoodServingItem>? items,
  }) {
    return FoodServing(
      id: id ?? this.id,
      label: label ?? this.label,
      items: items ?? this.items,
    );
  }

  @override
  String toString() {
    return 'FoodServing(id: $id, label: $label, items: $items)';
  }

  Macros getMacros(Map<String, Food> foodsById) {
    var macros = _emptyMacros;
    for (final item in items) {
      final food = foodsById[item.foodId];
      if (food == null || !item.isValid) continue;
      macros += _getItemMacros(food, item.servingSize);
    }
    return macros;
  }

  bool hasAvailableFoods(Map<String, Food> foodsById) {
    return items.isNotEmpty &&
        items.every(
            (item) => item.isValid && foodsById.containsKey(item.foodId));
  }

  bool containsFood(String id) {
    return items.any((item) => item.foodId == id);
  }

  Macros _getItemMacros(Food food, double servingSize) {
    final perUnitRatio = _unitRatio(food.unit);
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
