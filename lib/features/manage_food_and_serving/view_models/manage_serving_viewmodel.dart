
import 'package:flutter/cupertino.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/food_serving.dart';
import 'package:macro_diary/models/summary.dart';
import 'package:macro_diary/repositories/food_serving_repository.dart';
import 'package:uuid/uuid.dart';


class ManageServingViewmodel extends ChangeNotifier {
  final IServingRepository _repo;
  ManageServingViewmodel({ required IServingRepository repo }) : _repo = repo;

  bool _createMode = true; // false if serving & other existing data is loaded successfully
  bool get createMode => _createMode;

  FoodServing _serving = const FoodServing(id: "", foodId: "", servingSize: 0, label: "");
  FoodServing get serving => _serving;

  Macros _servingMacros =  Macros(protein: 0, carbs: 0, fats: 0, calories: 0);
  Macros get servingMacros => _servingMacros;

  FoodItem _relativeFood = FoodItem(id: "", name: "", unit: MeasureUnit.gram, macros: Macros(protein: 0, carbs: 0, fats: 0, calories: 0));
  FoodItem get relativeFood => _relativeFood;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Initial loading - Load Serving, macros and relative food
  Future<void> loadServing(String serveId, FoodItem food) async {
    _isLoading = true;
    notifyListeners();

    try{
      // Load Serving...
      final repoServing = await _repo.get(serveId);

      // Tried loading service but did not find in repo so it will be treated as creating new
      if(repoServing == null){
        /// #TODO: add error message of unable to load serving
        return;
      }

      // Load Macros of serving and serving relative food
      _createMode = false; /// We are editing a already existing serving
      _serving = repoServing; /// Custom Serving
      _servingMacros = _serving.getMacros(food); /// Macros of serving
      _relativeFood = food; /// Food for which serving is made
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  /// While setting the serving size we check estimated macros for the size using this...
  Macros getEstimatedMacros(int servingSize,FoodItem? selectedFood){
    if(!_createMode){// We are in edit mode...
      final tempServing = _serving.copyWith(servingSize: servingSize);
      return tempServing.getMacros(_relativeFood);
    }else if(selectedFood != null){ // Create temp serving...
      final tempServing = FoodServing(id: "", foodId: selectedFood.id, servingSize: servingSize,label: "Temp Label");
      return tempServing.getMacros(selectedFood);
    }
    return Macros(protein: 0, carbs: 0, fats: 0, calories: 0);
  }

  /// 2. Save – create or update based on presence of an ID
  Future<void> saveServing(FoodServing item) async {
    _isLoading = true;
    notifyListeners();

    final id = item.id.isEmpty ? const Uuid().v4() : item.id;
    final toSave = item.copyWith(id: id);

    if (await _repo.get(id) == null) {
      await _repo.create(toSave);
    } else {
      await _repo.update(toSave);
    }

    _isLoading = false;
    notifyListeners();
  }

}