
import 'package:flutter/cupertino.dart';
import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/features/manage_food_and_serving/view_models/manage_food_viewmodel.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/food_serving.dart';
import 'package:macro_diary/models/macros.dart';
import 'package:macro_diary/repositories/food_serving_repository.dart';

class ServingFormImputs {

  String title = "";
  int servingSize = 0;
  FoodItem relativeFood = FoodItem(id: "", name: "", unit: MeasureUnit.gram, macros: Macros(protein: 0, carbs: 0, fats: 0, calories: 0));

  @override
  String toString() {
    return 'FormImputs{name: $title, servingSize: $servingSize, relativeFood: ${relativeFood.toString()}} ';
  }
}

class ManageServingViewmodel extends ChangeNotifier {
  final IServingRepository _repo;
  ManageServingViewmodel({ required IServingRepository repo }) : _repo = repo;

  final ServingFormImputs formImputs = ServingFormImputs();

  bool _createMode = true; // false if serving & other existing data is loaded successfully
  bool get createMode => _createMode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FoodServing _serving = FoodServing(id: uuid.v4().toString(), foodId: "", servingSize: 0, label: "");
  FoodServing get serving => _serving;

  Macros _servingMacros =  Macros(protein: 0, carbs: 0, fats: 0, calories: 0);
  Macros get servingMacros => _servingMacros;

  List<FoodItem> _foods = [];
  List<FoodItem> get foods => _foods;

  /// Initial loading - Load Serving, macros and relative food
  Future<void> initialLoading(String? serveId, FoodItem? food, List<FoodItem> foods) async {

    _foods = foods;

    if (serveId == null || serveId.isEmpty) return;
    if(food == null) return; // here foodItem is relative food to which the serving is created...

    _isLoading = true;
    notifyListeners();

    try{
      // Load Serving...
      final repoServing = await _repo.get(serveId);

      // Tried loading service but did not find in repo so it will be treated as creating new
      if(repoServing == null){
        _createMode = true;
        return;
      }else{
        Util.print.debug("Initial Data in serving viewModel is ${_serving.toString()}");

        // Screen state elements....
        _createMode = false;
        _serving = repoServing; // Custom Serving

        _servingMacros = _serving.getMacros(food); // Macros of serving

        // Form state elements....
        formImputs.title = _serving.label;
        formImputs.servingSize = _serving.servingSize;
        formImputs.relativeFood = food;
      }
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSelectedFood(FoodItem food){
    formImputs.relativeFood = food;
    notifyListeners();
  }

  /// While setting the serving size we check estimated macros for the size using this...
  Macros _getEstimatedMacros(int servingSize,FoodItem? selectedFood){
    if(!_createMode){// We are in edit mode...
      final tempServing = _serving.copyWith(servingSize: servingSize);
      return tempServing.getMacros(formImputs.relativeFood);
    }else if(selectedFood != null){ // Create temp serving...
      final tempServing = FoodServing(id: "", foodId: selectedFood.id, servingSize: servingSize,label: "Temp Label");
      return tempServing.getMacros(selectedFood);
    }
    return Macros(protein: 0, carbs: 0, fats: 0, calories: 0);
  }

  /// 2. Save – create or update based on presence of an ID
  Future<void> saveServing({Function()? callback}) async {

    _isLoading = true;
    notifyListeners();
    Util.print.debug("Info for saving serving is: ${formImputs.toString()}");

    try{

      final serving = FoodServing(
        id: _serving.id,
        foodId: formImputs.relativeFood.id,
        servingSize: formImputs.servingSize,
        label: formImputs.title);

      _repo.create(serving);
      callback?.call();
    }
    catch(e){
      Util.print.error("saveServing: Failed to save serving $e");
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }

}