import 'package:flutter/cupertino.dart';
import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/models/food_serving.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/summary.dart';
import 'package:macro_diary/repositories/food_item_repository.dart';
import 'package:macro_diary/repositories/food_serving_repository.dart';
import 'package:macro_diary/repositories/summary_repository.dart';


class HomeScreenViewmodel extends ChangeNotifier{
  HomeScreenViewmodel({
    required IServingRepository servingRepo,
    required IFoodRepository foodRepo,
    required ISummaryRepository summaryRepo,
  }): _servingRepo = servingRepo, _foodRepo = foodRepo, _summaryRep = summaryRepo;

  // Repositories
  final IServingRepository _servingRepo;
  final IFoodRepository _foodRepo;
  final ISummaryRepository _summaryRep;

  // LoaderFlag
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Summary
  final Macros _sum = Macros(
    protein: 0,
    carbs: 0,
    fats: 0,
    calories: 0,
  );
  Macros get sum => _sum;


  // Food Items & Servings
  final Map<String, FoodItem> _foodMap = {};
  FoodItem? getFoodById(String id)=>_foodMap[id];
  List<FoodItem> _foodItems = [];
  List<FoodItem> get foodItems => _foodItems;
  List<FoodServing> _foodServings = [];
  List<FoodServing> get foodServings => _foodServings;

  // Methods....
  void _updateSummary(Macros macros){
    _sum.calories += macros.calories;
    _sum.protein += macros.protein;
    _sum.carbs += macros.carbs;
    _sum.fats += macros.fats;
  }

  void updateUsingFoodItem(FoodItem foodItem){
    _updateSummary(foodItem.macros);
    notifyListeners();
  }

  void updateUsingFoodServing(FoodServing serving) async{

    final relativeFood = await _foodRepo.get(serving.foodId);

    if(relativeFood == null){
      Util.print.error("relative food not found for $serving");
      /// #TODO: IMPLEMENT ERROR
      return;
    }

    final servingMacros = serving.getMacros(relativeFood);
    _updateSummary(servingMacros);
    notifyListeners();
  }

  loadContent()async{
    _isLoading = true;
    notifyListeners();

    // Get All Food Items
   _foodServings = await _servingRepo.getAll();

   // Get All Food Servings
   _foodItems =  await _foodRepo.getAll();
   for (var element in _foodItems) {
     _foodMap[element.id] = element;
   }

   // Get Summary
   final pastSummary = await _summaryRep.getCurrentSummary();
    _updateSummary(pastSummary);

    Util.print.debug("completed loading content ====${_foodItems.length} ${_foodServings.length} ");

    _isLoading = false;
    notifyListeners();
  }
}