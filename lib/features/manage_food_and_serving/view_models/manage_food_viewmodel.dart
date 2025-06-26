
import 'package:flutter/cupertino.dart';
import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/macros.dart';
import 'package:macro_diary/repositories/food_item_repository.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class FoodFormImputs {

  String name = "";
  MeasureUnit unit = MeasureUnit.gram;
  Macros macros = Macros(protein: 0, carbs: 0, fats: 0, calories: 0);

  @override
  String toString() {
    return 'FormImputs{name: $name, unit: $unit, macros: $macros}';
  }

}

class ManageFoodViewmodel extends ChangeNotifier {
  final IFoodRepository _repo;
  ManageFoodViewmodel({ required IFoodRepository repo }) : _repo = repo;

  // Manage form
  final FoodFormImputs formImputs = FoodFormImputs();

  bool _createMode = true; // false if editing food
  bool get createMode => _createMode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FoodItem _food = FoodItem(id: uuid.v4().toString(), name: "", macros: Macros(protein: 0, carbs: 0, fats: 0, calories: 0), unit: MeasureUnit.gram);
  FoodItem get food => _food;

   // Load Food item if editing
   Future<void> initialLoading(String? foodId) async {
     if (foodId == null || foodId.isEmpty) return;

     _isLoading = true;
     notifyListeners();

     try{
       var tempFood = await _repo.get(foodId);
        if(tempFood==null){
          _createMode = true;
          return;
        }else{
          Util.print.debug("Initial Data in food viewModel is ${_food.toString()}");

          _createMode = false;
          _food = tempFood;

          // Setup formInputs
          formImputs.name = _food.name;
          formImputs.unit = _food.unit;
          formImputs.macros = _food.macros;
        }

     }finally{
       _isLoading = false;
       notifyListeners();
     }
   }

  /// 2. Save – create or update based on presence of an ID
  Future<void> saveFood({Function()? callback}) async {
    _isLoading = true;
    notifyListeners();

    try{
      Util.print.debug("Info for saving food is: ${formImputs.toString()}");

      final foodItem = FoodItem(
        name: formImputs.name,
        unit: formImputs.unit,
        macros: formImputs.macros,
        id: _food.id,
      );

      _repo.create(foodItem);

    }catch(e){
      Util.print.error("Failed to save food Item");
    }finally{
      _isLoading = false;
      notifyListeners();
      callback?.call(); // call the callback if any
    }
  }

}