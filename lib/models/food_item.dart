import 'package:macro_diary/models/summary.dart';

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

  factory FoodItem.fromJson(Map<String, dynamic> json){
    return FoodItem();
  }
}
