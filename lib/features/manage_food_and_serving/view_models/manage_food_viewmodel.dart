
import 'package:flutter/cupertino.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/summary.dart';
import 'package:macro_diary/repositories/food_item_repository.dart';
import 'package:uuid/uuid.dart';

class ManageFoodViewmodel extends ChangeNotifier {
  final IFoodRepository _repo;
  ManageFoodViewmodel({ required IFoodRepository repo }) : _repo = repo;

  bool _createMode = true; // false if editing food
  bool get createMode => _createMode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FoodItem _food = FoodItem(id: "", name: "", macros: Macros(protein: 0, carbs: 0, fats: 0, calories: 0), unit: MeasureUnit.gram);
  FoodItem get food => _food;

   // Load Food item if editing
   Future<void> initialLoading(String? foodId) async {
     if (foodId == null) return;

     _isLoading = true;
     notifyListeners();

     try{
       final tempFood = await _repo.get(foodId);
        if(tempFood==null){
          _createMode = true;
          return;
        }else{
          _createMode = false;
          _food = tempFood;
        }

     }finally{
       _isLoading = false;
       notifyListeners();
     }


   }

  /// 2. Save – create or update based on presence of an ID
  Future<void> saveFood(FoodItem item) async {
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