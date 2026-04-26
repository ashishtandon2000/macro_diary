class Macros {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  const Macros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  // Business Logic: Addition
  Macros operator +(Macros other) {
    return Macros(
      calories: calories + other.calories,
      protein: _round(protein + other.protein),
      carbs: _round(carbs + other.carbs),
      fats: _round(fats + other.fats),
    );
  }

  // Business Logic: Subtraction
  Macros operator -(Macros other) {
    return Macros(
      calories: calories - other.calories,
      protein: _round(protein - other.protein),
      carbs: _round(carbs - other.carbs),
      fats: _round(fats - other.fats),
    );
  }

  // Pure helper - internal to the domain
  static double _round(double val) => double.parse(val.toStringAsFixed(2));

  @override
  String toString() => 'Macros(kcal: $calories, P: $protein, C: $carbs, F: $fats)';

  Macros copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
  }){
    return Macros(calories: calories??this.calories, protein: protein??this.protein, carbs: carbs??this.carbs, fats: fats??this.fats);
  }
}