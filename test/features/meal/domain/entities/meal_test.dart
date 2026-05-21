import 'package:flutter_test/flutter_test.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/meal/domain/entities/meal.dart';

void main() {
  test('calculates macros from multiple food items', () {
    const milk = Food(
      id: 'milk',
      name: 'Milk',
      macros: Macros(calories: 60, protein: 3.2, carbs: 4.8, fats: 3.3),
      unit: MeasureUnit.milliliter,
    );
    const egg = Food(
      id: 'egg',
      name: 'Egg',
      macros: Macros(calories: 70, protein: 6, carbs: 0.5, fats: 5),
      unit: MeasureUnit.piece,
    );
    const bread = Food(
      id: 'bread',
      name: 'Bread',
      macros: Macros(calories: 80, protein: 3, carbs: 15, fats: 1),
      unit: MeasureUnit.piece,
    );

    const meal = Meal(
      id: 'meal',
      label: 'Breakfast',
      items: [
        MealItem(foodId: 'milk', amount: 200),
        MealItem(foodId: 'egg', amount: 2),
        MealItem(foodId: 'bread', amount: 2),
      ],
    );

    final macros = meal.getMacros({
      milk.id: milk,
      egg.id: egg,
      bread.id: bread,
    });

    expect(macros.calories, 420);
    expect(macros.protein, 24.4);
    expect(macros.carbs, 40.6);
    expect(macros.fats, 18.6);
  });
}
