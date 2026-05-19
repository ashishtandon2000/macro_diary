import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/food/data/repositories/food_repository_impl.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/food/domain/repositories/food_repository.dart';
import 'package:macro_diary/features/meal/domain/entities/meal.dart';
import 'package:macro_diary/features/meal/domain/repositories/meal_repository.dart';

import '../../data/repositories/meal_repository_impl.dart';

const _emptyMacros = Macros(calories: 0, protein: 0, carbs: 0, fats: 0);
const _emptyFood = Food(
  id: "",
  name: "",
  macros: _emptyMacros,
  unit: MeasureUnit.gram,
);

final manageMealProvider =
    NotifierProvider.autoDispose<ManageMealNotifier, ManageMealState>(
        ManageMealNotifier.new);

class ManageMealNotifier extends AutoDisposeNotifier<ManageMealState> {
  MealRepository get _repository => ref.read(mealRepositoryProvider);
  FoodRepository get _foodRepository => ref.read(foodRepositoryProvider);

  @override
  ManageMealState build() {
    return const ManageMealState();
  }

  Future<void> initialLoading(String? mealId) async {
    state = state.copyWith(isLoading: true, errorMessage: "");

    try {
      final isEditing = mealId != null && mealId.isNotEmpty;
      final foodsFuture = _foodRepository.getAllFoods();
      final mealFuture = isEditing
          ? _repository.getMealById(mealId)
          : Future<Meal?>.value(null);

      final meal = await mealFuture;
      final foods = await foodsFuture;
      final items = meal == null
          ? [
              MealFoodInput(
                food: foods.isNotEmpty ? foods.first : _emptyFood,
                amount: 1,
              ),
            ]
          : meal.items
              .map(
                (item) => MealFoodInput(
                  food: _findFoodById(foods, item.foodId) ?? _emptyFood,
                  amount: item.amount,
                ),
              )
              .toList();

      String errorMessage = "";
      if (foods.isEmpty) {
        errorMessage = "Add a food item before creating a meal.";
      } else if (isEditing && meal == null) {
        errorMessage = "Meal not found.";
      } else if (meal != null && items.any((item) => item.food.id.isEmpty)) {
        errorMessage = "Some food items for this meal are no longer available.";
      }

      state = state.copyWith(
        createMode: meal == null,
        meal: meal,
        foods: foods,
        errorMessage: errorMessage,
        formInputs: meal == null
            ? state.formInputs.copyWith(items: items)
            : MealFormInputs(
                title: meal.label,
                items: items,
              ),
      );
    } catch (_) {
      state = state.copyWith(
        errorMessage: "Failed to load meal details.",
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> saveMeal() async {
    final validationMessage = _validationMessage();
    if (validationMessage != null) {
      state = state.copyWith(errorMessage: validationMessage);
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: "");

    try {
      final meal = Meal(
        id: state.createMode ? "" : state.meal?.id ?? "",
        label: state.formInputs.title.trim(),
        items: state.formInputs.items
            .map(
              (item) => MealItem(
                foodId: item.food.id,
                amount: item.amount,
              ),
            )
            .toList(),
      );

      final savedMeal = state.createMode
          ? await _repository.addMeal(meal)
          : await _repository.updateMeal(meal);

      if (state.createMode) {
        state = state.copyWith(
          meal: savedMeal,
          createMode: false,
          formInputs: state.formInputs.copyWith(
            title: savedMeal.label,
          ),
        );
      } else {
        state = state.copyWith(meal: savedMeal);
      }
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: "Failed to save meal.");
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Macros getEstimatedMacros() {
    final foodMap = {for (final food in state.foods) food.id: food};
    final tempMeal = Meal(
      id: "",
      label: "Temp Label",
      items: state.formInputs.items
          .map(
            (item) => MealItem(
              foodId: item.food.id,
              amount: item.amount,
            ),
          )
          .toList(),
    );
    return tempMeal.getMacros(foodMap);
  }

  void updateInputs({String? title}) {
    if (title == null) return;

    final update = state.formInputs.copyWith(title: title);
    state = state.copyWith(formInputs: update, errorMessage: "");
  }

  void updateItem(int index, {Food? food, double? amount}) {
    if (index < 0 || index >= state.formInputs.items.length) return;

    final items = [...state.formInputs.items];
    items[index] = items[index].copyWith(
      food: food,
      amount: amount,
    );
    state = state.copyWith(
      formInputs: state.formInputs.copyWith(items: items),
      errorMessage: "",
    );
  }

  void addItem() {
    if (state.foods.isEmpty) return;
    state = state.copyWith(
      formInputs: state.formInputs.copyWith(
        items: [
          ...state.formInputs.items,
          MealFoodInput(food: state.foods.first, amount: 1),
        ],
      ),
      errorMessage: "",
    );
  }

  void removeItem(int index) {
    if (state.formInputs.items.length <= 1 ||
        index < 0 ||
        index >= state.formInputs.items.length) {
      return;
    }

    final items = [...state.formInputs.items]..removeAt(index);
    state = state.copyWith(
      formInputs: state.formInputs.copyWith(items: items),
      errorMessage: "",
    );
  }

  String? _validationMessage() {
    if (state.formInputs.title.trim().isEmpty) {
      return "Please enter a meal title.";
    }
    if (state.formInputs.items.isEmpty) {
      return "Please add at least one food item.";
    }
    for (final item in state.formInputs.items) {
      if (item.food.id.isEmpty) {
        return "Please select a food item for each row.";
      }
      if (item.amount <= 0 || !item.amount.isFinite) {
        return "Each food amount must be greater than zero.";
      }
    }
    return null;
  }

  Food? _findFoodById(List<Food> foods, String foodId) {
    for (final food in foods) {
      if (food.id == foodId) return food;
    }
    return null;
  }
}

class MealFoodInput {
  final Food food;
  final double amount;

  const MealFoodInput({
    required this.food,
    required this.amount,
  });

  MealFoodInput copyWith({
    Food? food,
    double? amount,
  }) {
    return MealFoodInput(
      food: food ?? this.food,
      amount: amount ?? this.amount,
    );
  }
}

class MealFormInputs {
  final String title;
  final List<MealFoodInput> items;

  const MealFormInputs(
      {this.title = "",
      this.items = const [
        MealFoodInput(food: _emptyFood, amount: 1),
      ]});

  MealFormInputs copyWith({String? title, List<MealFoodInput>? items}) {
    return MealFormInputs(
      title: title ?? this.title,
      items: items ?? this.items,
    );
  }
}

class ManageMealState {
  final MealFormInputs formInputs;
  final bool isLoading;
  final bool createMode;
  final Meal? meal;
  final List<Food> foods;
  final String errorMessage;

  const ManageMealState(
      {this.formInputs = const MealFormInputs(),
      this.isLoading = true,
      this.createMode = true,
      this.meal,
      this.foods = const [],
      this.errorMessage = ""});

  ManageMealState copyWith(
      {MealFormInputs? formInputs,
      bool? isLoading,
      bool? createMode,
      Meal? meal,
      List<Food>? foods,
      String? errorMessage}) {
    return ManageMealState(
      formInputs: formInputs ?? this.formInputs,
      isLoading: isLoading ?? this.isLoading,
      createMode: createMode ?? this.createMode,
      meal: meal ?? this.meal,
      foods: foods ?? this.foods,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
