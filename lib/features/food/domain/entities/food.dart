import 'package:macro_diary/core/domain/entities/macros.dart';

enum MeasureUnit { gram, milliliter, piece }

class Food {
  final String id;
  final String? externalId; // In case if food data is fetched from external Data Source
  final String name;
  final Macros macros;
  final MeasureUnit unit;

  const Food({
    required this.id,
    required this.name,
    required this.macros,
    required this.unit,
    this.externalId
  });

  Food copyWith({
    String? id,
    String? name,
    Macros? macros,
    MeasureUnit? unit,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      macros: macros ?? this.macros,
      unit: unit ?? this.unit,
    );
  }

  @override
  String toString() => 'Food(id: $id, name: $name)';
}