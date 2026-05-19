import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';

const _emptyMacros = Macros(calories: 0, protein: 0, carbs: 0, fats: 0);

class MealItem {
  final String foodId;
  final double amount;

  const MealItem({
    required this.foodId,
    required this.amount,
  });

  MealItem copyWith({
    String? foodId,
    double? amount,
  }) {
    return MealItem(
      foodId: foodId ?? this.foodId,
      amount: amount ?? this.amount,
    );
  }

  bool get isValid => foodId.isNotEmpty && amount > 0 && amount.isFinite;

  @override
  String toString() {
    return 'MealItem(foodId: $foodId, amount: $amount)';
  }
}

class Meal {
  final String id;
  final String label;
  final List<MealItem> items;

  const Meal({
    required this.id,
    required this.label,
    required this.items,
  });

  String get foodId => items.isEmpty ? "" : items.first.foodId;
  double get amount => items.isEmpty ? 0 : items.first.amount;
  List<String> get foodIds => items.map((item) => item.foodId).toList();

  Meal copyWith({
    String? id,
    String? label,
    List<MealItem>? items,
  }) {
    return Meal(
      id: id ?? this.id,
      label: label ?? this.label,
      items: items ?? this.items,
    );
  }

  @override
  String toString() {
    return 'Meal(id: $id, label: $label, items: $items)';
  }

  Macros getMacros(Map<String, Food> foodsById) {
    var macros = _emptyMacros;
    for (final item in items) {
      final food = foodsById[item.foodId];
      if (food == null || !item.isValid) continue;
      macros += _getItemMacros(food, item.amount);
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

  Macros _getItemMacros(Food food, double amount) {
    final perUnitRatio = _unitRatio(food.unit);
    return Macros(
      calories:
          food.macros.calories.toDouble() * perUnitRatio * amount.toDouble(),
      carbs: food.macros.carbs * perUnitRatio * amount.toDouble(),
      protein: food.macros.protein * perUnitRatio * amount.toDouble(),
      fats: food.macros.fats * perUnitRatio * amount.toDouble(),
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
//   'amount': amount,
// };
//
// factory Meal.fromJson(Map<String, dynamic> json){
//   return Meal(
//       id: Util.fGetMapSafely<String>(data: json,key: "id"),
//       label: Util.fGetMapSafely<String>(data: json,key: "label"),
//       foodId: Util.fGetMapSafely<String>(data: json,key: "foodId"),
//       amount: Util.fGetMapSafely<int>(data: json, key: "amount")
//   );
// }
//
}
