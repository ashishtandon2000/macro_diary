import 'package:macro_diary/models/food_serving.dart';

abstract class IServingRepository {
  Future<FoodServing?> get(String servingId);
  Future<List<FoodServing>> getAll();
  Future<void> create(FoodServing serving);
  Future<void> update(FoodServing serving);
  Future<void> delete(String servingId);
}
const testServing = FoodServing(
  id: 'serv-apple-150g',
  label: 'Apple (150 g)',
  foodId: 'apple-100g',
  servingSize: 150,
);

const List<FoodServing> testServings = [
  FoodServing(
    id: 'serv-apple-150g',
    label: 'Apple (150 g)',
    foodId: 'apple-100g',
    servingSize: 150,
  ),
  FoodServing(
    id: 'serv-banana-1',
    label: 'Banana (1 medium)',
    foodId: 'banana-piece',
    servingSize: 1,
  ),
  FoodServing(
    id: 'serv-rice-200g',
    label: 'Cooked Rice (200 g)',
    foodId: 'rice-100g',
    servingSize: 200,
  ),
  FoodServing(
    id: 'serv-chicken-1',
    label: 'Chicken Breast (1 piece ~120 g)',
    foodId: 'chicken-100g',
    servingSize: 120,
  ),
  FoodServing(
    id: 'serv-milk-250ml',
    label: 'Milk (250 ml)',
    foodId: 'milk-100ml',
    servingSize: 250,
  ),
  FoodServing(
    id: 'serv-bread-2',
    label: 'Whole Wheat Bread (2 slices)',
    foodId: 'bread-slice',
    servingSize: 2,
  ),
  FoodServing(
    id: 'serv-egg-2',
    label: 'Eggs (2 large)',
    foodId: 'egg-large',
    servingSize: 2,
  ),
];

class ServingRepositoryImpl implements IServingRepository{

  @override
  Future<FoodServing> get(String servingId) async {
    return testServing;
  }

  @override
  Future<List<FoodServing>> getAll()async{
    return testServings;
  }

  @override
  Future<void> create(FoodServing serving)async{}

  @override
  Future<void> update(FoodServing serving)async{}

  @override
  Future<void> delete(String servingId)async{}
}