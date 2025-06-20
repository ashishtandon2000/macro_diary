
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/summary.dart';

abstract class IFoodRepository { // I is standard used for interfaces

  Future<List<FoodItem>> getAll();
  Future<FoodItem?> get(String foodId);
  Future<void> create(FoodItem item);
  Future<void> update(FoodItem item);
  Future<void> delete(String foodId);
}

final List<FoodItem> testFoodItems = [
  FoodItem(
    id: 'apple-100g',
    name: 'Apple',
    unit: MeasureUnit.gram,
    macros: Macros(
      calories: 52,
      protein: 0.3,
      carbs: 14,
      fats: 0.2,
    ),
  ),
  FoodItem(
    id: 'banana-piece',
    name: 'Banana (medium)',
    unit: MeasureUnit.piece,
    macros: Macros(
      calories: 105,
      protein: 1.3,
      carbs: 27,
      fats: 0.3,
    ),
  ),
  FoodItem(
    id: 'rice-100g',
    name: 'Cooked Rice',
    unit: MeasureUnit.gram,
    macros: Macros(
      calories: 130,
      protein: 2.4,
      carbs: 28,
      fats: 0.3,
    ),
  ),
  FoodItem(
    id: 'chicken-100g',
    name: 'Chicken Breast',
    unit: MeasureUnit.gram,
    macros: Macros(
      calories: 165,
      protein: 31,
      carbs: 0,
      fats: 3.6,
    ),
  ),
  FoodItem(
    id: 'milk-100ml',
    name: 'Milk (100 ml)',
    unit: MeasureUnit.milliliter,
    macros: Macros(
      calories: 61,
      protein: 3.2,
      carbs: 4.8,
      fats: 3.3,
    ),
  ),
  FoodItem(
    id: 'bread-slice',
    name: 'Whole Wheat Bread',
    unit: MeasureUnit.piece,
    macros: Macros(
      calories: 70,
      protein: 3.5,
      carbs: 12,
      fats: 1,
    ),
  ),
  FoodItem(
    id: 'egg-large',
    name: 'Egg (large)',
    unit: MeasureUnit.piece,
    macros: Macros(
      calories: 78,
      protein: 6.3,
      carbs: 0.6,
      fats: 5.3,
    ),
  ),
];


class FoodRepositoryImpl    implements IFoodRepository    {

  @override
  Future<List<FoodItem>> getAll()async{
    return testFoodItems;
  }

  @override
  Future<FoodItem?> get(String foodId)async{
    for(var item in testFoodItems){
      if(item.id == foodId){
        return item;
      }
    }
    return null;
  }

  @override
  Future<void> create(FoodItem item)async{}

  @override
  Future<void> update(FoodItem item)async{}

  @override
  Future<void> delete(String foodId)async{}
}

