import 'package:isar/isar.dart';
import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';

part 'food_serving_isar.g.dart';

@collection
class FoodServingIsar {
  Id id = Isar.autoIncrement;
  String label = "";

  // Legacy single-food fields. Kept so existing saved servings can be read
  // and treated as a one-item meal.
  String foodId = "";
  double servingSize = 0;

  List<String> foodIds = [];
  List<double> servingSizes = [];

  FoodServing toEntity() {
    return FoodServing(
      id: id.toString(),
      label: label,
      items: _servingItems(),
    );
  }

  static FoodServingIsar fromEntity(FoodServing serving) {
    final firstItem = serving.items.isNotEmpty ? serving.items.first : null;
    return FoodServingIsar()
      ..label = serving.label
      ..foodId = firstItem?.foodId ?? ""
      ..servingSize = firstItem?.servingSize ?? 0
      ..foodIds = serving.items.map((item) => item.foodId).toList()
      ..servingSizes = serving.items.map((item) => item.servingSize).toList();
  }

  static FoodServingIsar fromEntityWithId(FoodServing serving) {
    return fromEntity(serving)..id = int.parse(serving.id);
  }

  List<FoodServingItem> _servingItems() {
    if (foodIds.isEmpty) {
      if (foodId.isEmpty) return [];
      return [
        FoodServingItem(foodId: foodId, servingSize: servingSize),
      ];
    }

    final items = <FoodServingItem>[];
    for (var index = 0; index < foodIds.length; index++) {
      final itemServingSize =
          index < servingSizes.length ? servingSizes[index] : 0.0;
      items.add(
        FoodServingItem(
          foodId: foodIds[index],
          servingSize: itemServingSize,
        ),
      );
    }
    return items;
  }
}
