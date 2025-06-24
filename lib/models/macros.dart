import 'package:macro_diary/common/common.dart';

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
    'fats': fats,
    'calories': calories
  };

  factory Macros.fromJson(Map<String, dynamic> json) {
    Util.print.debug("json is $json");
    return Macros(
      calories: Util.fGetMapSafely<int>(data: json,key: "calories"),
      protein: Util.fGetMapSafely<double>(data: json,key: "protein"),
      carbs: Util.fGetMapSafely<double>(data: json,key: "carbs"),
      fats: Util.fGetMapSafely<double>(data: json,key: "fats"),
    );
  }
}
