import 'package:isar/isar.dart';
import 'package:macro_diary/features/meal/domain/entities/meal.dart';

part 'meal_isar.g.dart';

@collection
@Name("FoodServingIsar")
class MealIsar {
  Id id = Isar.autoIncrement;
  String label = "";

  // Single-food fields allow one-item meals to be stored compactly.
  String foodId = "";
  @Name("servingSize")
  double amount = 0;

  List<String> foodIds = [];
  @Name("servingSizes")
  List<double> amounts = [];

  Meal toEntity() {
    return Meal(
      id: id.toString(),
      label: label,
      items: _mealItems(),
    );
  }

  static MealIsar fromEntity(Meal meal) {
    final firstItem = meal.items.isNotEmpty ? meal.items.first : null;
    return MealIsar()
      ..label = meal.label
      ..foodId = firstItem?.foodId ?? ""
      ..amount = firstItem?.amount ?? 0
      ..foodIds = meal.items.map((item) => item.foodId).toList()
      ..amounts = meal.items.map((item) => item.amount).toList();
  }

  static MealIsar fromEntityWithId(Meal meal) {
    return fromEntity(meal)..id = int.parse(meal.id);
  }

  List<MealItem> _mealItems() {
    if (foodIds.isEmpty) {
      if (foodId.isEmpty) return [];
      return [
        MealItem(foodId: foodId, amount: amount),
      ];
    }

    final items = <MealItem>[];
    for (var index = 0; index < foodIds.length; index++) {
      final itemAmount = index < amounts.length ? amounts[index] : 0.0;
      items.add(
        MealItem(
          foodId: foodIds[index],
          amount: itemAmount,
        ),
      );
    }
    return items;
  }
}
