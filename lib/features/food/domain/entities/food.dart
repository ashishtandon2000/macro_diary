import 'package:macro_diary/core/domain/entities/macros.dart';

enum MeasureUnit { gram, milliliter, piece }

class Food {
  final String id;
  // In case food data is fetched from an external data source.
  final String? externalId;
  final String name;
  final Macros macros;
  final MeasureUnit unit;

  const Food({
    required this.id,
    required this.name,
    required this.macros,
    required this.unit,
    this.externalId,
  });

  Food copyWith({
    String? id,
    String? name,
    Macros? macros,
    MeasureUnit? unit,
    String? externalId,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      macros: macros ?? this.macros,
      unit: unit ?? this.unit,
      externalId: externalId ?? this.externalId,
    );
  }

  @override
  String toString() => 'Food(id: $id, name: $name)';
}