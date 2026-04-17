import 'package:isar/isar.dart';

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
}