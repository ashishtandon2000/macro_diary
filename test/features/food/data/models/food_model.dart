import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/core/errors/exceptions.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';

class FoodModel {
  final String id; // local id (can be empty for API results)
  final String name;
  final Macros macros;
  final MeasureUnit unit;
  final String? externalId;

  const FoodModel({
    required this.id,
    required this.name,
    required this.macros,
    required this.unit,
    this.externalId,
  });

  //  USDA -> Model
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    try {
      final nutrients = json['foodNutrients'] as List?;

      return FoodModel(
        id: '', // API items don’t have local id yet
        name: json['description'] ?? 'Unknown',
        macros: _extractMacros(nutrients ?? []),
        unit: _getUnit(json['servingSizeUnit']),
        externalId: json['fdcId']?.toString(),
      );
    } catch (e) {
      throw ParsingException("Failed to parse FoodModel: $e");
    }
  }

  // Model → Entity
  Food toEntity() {
    return Food(
      id: id,
      name: name,
      macros: macros,
      unit: unit,
      externalId: externalId,
    );
  }

  // Extract macros safely
  static Macros _extractMacros(List foodNutrients) {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fats = 0;

    for (final nutrient in foodNutrients) {
      final id = nutrient['nutrientId'];
      final value = (nutrient['value'] ?? 0).toDouble();

      switch (id) {
        case 1008: // Energy (kcal)
          calories = value;
          break;
        case 1003: // Protein
          protein = value;
          break;
        case 1005: // Carbohydrates
          carbs = value;
          break;
        case 1004: // Fat
          fats = value;
          break;
      }
    }

    return Macros(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
    );
  }

  // 🔥 Unit mapping
  static MeasureUnit _getUnit(dynamic servingSizeUnit) {
    if (servingSizeUnit == null) return MeasureUnit.gram;

    switch (servingSizeUnit.toString().toLowerCase()) {
      case 'g':
        return MeasureUnit.gram;
      case 'ml':
        return MeasureUnit.milliliter;
      default:
        return MeasureUnit.piece;
    }
  }
}