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

  Map<String, dynamic> toJson() => {
    'protein': protein,
    'carbs': carbs,
    'fat': fats,
    'calories': calories
  };

  factory Macros.fromJson(Map<String, dynamic> json) {
    return Macros(
      calories: json['calories']?? 0,
      protein: json['protein'] ?? 0.0,
      carbs: json['carbs'] ?? 0.0,
      fats: json['fat'] ?? 0.0,
    );
  }
}
