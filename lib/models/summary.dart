class Macros {
  int calories = 0;
  double protein = 0;
  double carbs = 0;
  double fats = 0;

  @override
  String toString(){
    return 'Macros(calories: $calories, protein: $protein, carbs: $carbs, fats: $fats)';
  }

  Macros(
      {required this.calories,
      required this.protein,
      required this.carbs,
      required this.fats});
}
