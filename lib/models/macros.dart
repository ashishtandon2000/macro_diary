import 'package:macro_diary/common/common.dart';

class Macros {
  int calories = 0;
  double protein = 0;
  double carbs = 0;
  double fats = 0;

  Macros({required this.calories,
      required double protein,
      required double carbs,
      required double fats}){

    this.protein = _roundAsDouble(protein);
    this.carbs = _roundAsDouble(carbs);
    this.fats = _roundAsDouble(fats);
  }

  @override
  String toString(){
    return 'Macros(calories: $calories, protein: $protein, carbs: $carbs, fats: $fats)';
  }

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

  void add(Macros other){
    calories += other.calories;
    protein = _roundAsDouble(other.protein+protein);
    carbs =  _roundAsDouble(other.carbs+carbs);
    fats =  _roundAsDouble(other.fats+fats);
  }

  void subtract(Macros other){
    calories -= other.calories;
    protein = _roundAsDouble(protein-other.protein);
    carbs =  _roundAsDouble(carbs-other.carbs);
    fats =  _roundAsDouble(fats-other.fats);
  }

  void reset(){
    calories = 0;
    protein = 0;
    carbs = 0;
    fats = 0;
  }

  double _roundAsDouble(double value){
    double rounded = double.parse(value.toStringAsFixed(2));
    return rounded;
  }
}
