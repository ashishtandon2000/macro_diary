import 'package:macro_diary/models/macros.dart';

enum MeasureUnit { gram, milliliter, piece }

class FoodItem {
  final String id;
  final String name;

  // Macros per standard - 100 gram, ml, 1 piece
  final Macros macros;

  final MeasureUnit unit;

  FoodItem(
      {required this.id,
      required this.name,
      required this.macros,
      required this.unit});

  @override
  String toString(){
    return 'FoodItem(id: $id, name: $name, unit: $unit, macros: ${macros.toString()})';
  }

  /// Returns a new FoodItem, replacing only the fields you pass in.
  FoodItem copyWith(
      {String? id,
      String? name,
      Macros? macros,
      MeasureUnit? unit}) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      macros: macros?? this.macros,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'macros': macros.toJson(),
    'unit': unit.name, // since Dart >= 2.15, use `name` instead of string splitting
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      macros: Macros.fromJson(json['macros'] as Map<String, dynamic>),
      unit: MeasureUnit.values.firstWhere(
            (e) => e.toString().split('.').last == json['unit'],
        orElse: () => MeasureUnit.gram, // fallback if invalid
      ),
    );
  }
}
