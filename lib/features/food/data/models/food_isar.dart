import 'package:isar/isar.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';

part 'food_isar.g.dart';

@collection
class FoodIsar {
  Id id = Isar.autoIncrement;

  String name = '';

  double calories = 0;
  double protein = 0;
  double carbs = 0;
  double fats = 0;

  String unit = 'gram';

  String? externalId;

  Food toEntity() {
    return Food(
      id: id.toString(),
      name: name,
      macros: Macros(
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
      ),
      unit: MeasureUnit.values.firstWhere((e) => e.name == unit),
      externalId: externalId

    );
  }

  static FoodIsar fromEntity(Food entity) {
    return FoodIsar()
      ..name = entity.name
      ..calories = entity.macros.calories
      ..protein = entity.macros.protein
      ..carbs = entity.macros.carbs
      ..fats = entity.macros.fats
      ..unit = entity.unit.name
      ..externalId = entity.externalId;
  }
}