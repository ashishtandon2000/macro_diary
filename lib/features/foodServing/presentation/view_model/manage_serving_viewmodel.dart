import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/food/data/repositories/food_repository_impl.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/food/domain/repositories/food_repository.dart';
import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';
import 'package:macro_diary/features/foodServing/domain/repositories/food_serving_repository.dart';

import '../../data/repositories/food_serving_repository_impl.dart';

const _emptyMacros = Macros(calories: 0, protein: 0, carbs: 0, fats: 0);
const _emptyFood = Food(
  id: "",
  name: "",
  macros: _emptyMacros,
  unit: MeasureUnit.gram,
);

final manageServingProvider =
    NotifierProvider.autoDispose<ManageServingNotifier, ManageServingState>(
        ManageServingNotifier.new);

class ManageServingNotifier extends AutoDisposeNotifier<ManageServingState> {
  FoodServingRepository get _repository => ref.read(servingRepositoryProvider);
  FoodRepository get _foodRepository => ref.read(foodRepositoryProvider);

  @override
  ManageServingState build() {
    return const ManageServingState();
  }

  Future<void> initialLoading(String? servingId) async {
    state = state.copyWith(isLoading: true, errorMessage: "");

    try {
      final isEditing = servingId != null && servingId.isNotEmpty;
      final foodsFuture = _foodRepository.getAllFoods();
      final servingFuture = isEditing
          ? _repository.getServingById(servingId)
          : Future<FoodServing?>.value(null);

      final serving = await servingFuture;
      final foods = await foodsFuture;
      final items = serving == null
          ? [
              ServingFoodInput(
                food: foods.isNotEmpty ? foods.first : _emptyFood,
                servingSize: 1,
              ),
            ]
          : serving.items
              .map(
                (item) => ServingFoodInput(
                  food: _findFoodById(foods, item.foodId) ?? _emptyFood,
                  servingSize: item.servingSize,
                ),
              )
              .toList();

      String errorMessage = "";
      if (foods.isEmpty) {
        errorMessage = "Add a food item before creating a serving.";
      } else if (isEditing && serving == null) {
        errorMessage = "Serving not found.";
      } else if (serving != null && items.any((item) => item.food.id.isEmpty)) {
        errorMessage =
            "Some food items for this serving are no longer available.";
      }

      state = state.copyWith(
        createMode: serving == null,
        serving: serving,
        foods: foods,
        errorMessage: errorMessage,
        formInputs: serving == null
            ? state.formInputs.copyWith(items: items)
            : ServingFormInputs(
                title: serving.label,
                items: items,
              ),
      );
    } catch (_) {
      state = state.copyWith(
        errorMessage: "Failed to load serving details.",
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> saveFoodServing() async {
    final validationMessage = _validationMessage();
    if (validationMessage != null) {
      state = state.copyWith(errorMessage: validationMessage);
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: "");

    try {
      final serving = FoodServing(
        id: state.createMode ? "" : state.serving?.id ?? "",
        label: state.formInputs.title.trim(),
        items: state.formInputs.items
            .map(
              (item) => FoodServingItem(
                foodId: item.food.id,
                servingSize: item.servingSize,
              ),
            )
            .toList(),
      );

      final savedServing = state.createMode
          ? await _repository.addServing(serving)
          : await _repository.updateServing(serving);

      if (state.createMode) {
        state = state.copyWith(
          serving: savedServing,
          createMode: false,
          formInputs: state.formInputs.copyWith(
            title: savedServing.label,
          ),
        );
      } else {
        state = state.copyWith(serving: savedServing);
      }
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: "Failed to save serving.");
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Macros getEstimatedMacros() {
    final foodMap = {for (final food in state.foods) food.id: food};
    final tempServing = FoodServing(
      id: "",
      label: "Temp Label",
      items: state.formInputs.items
          .map(
            (item) => FoodServingItem(
              foodId: item.food.id,
              servingSize: item.servingSize,
            ),
          )
          .toList(),
    );
    return tempServing.getMacros(foodMap);
  }

  void updateInputs({String? title}) {
    if (title == null) return;

    final update = state.formInputs.copyWith(title: title);
    state = state.copyWith(formInputs: update, errorMessage: "");
  }

  void updateItem(int index, {Food? food, double? servingSize}) {
    if (index < 0 || index >= state.formInputs.items.length) return;

    final items = [...state.formInputs.items];
    items[index] = items[index].copyWith(
      food: food,
      servingSize: servingSize,
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
          ServingFoodInput(food: state.foods.first, servingSize: 1),
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
      return "Please enter a serving title.";
    }
    if (state.formInputs.items.isEmpty) {
      return "Please add at least one food item.";
    }
    for (final item in state.formInputs.items) {
      if (item.food.id.isEmpty) {
        return "Please select a food item for each row.";
      }
      if (item.servingSize <= 0 || !item.servingSize.isFinite) {
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

class ServingFoodInput {
  final Food food;
  final double servingSize;

  const ServingFoodInput({
    required this.food,
    required this.servingSize,
  });

  ServingFoodInput copyWith({
    Food? food,
    double? servingSize,
  }) {
    return ServingFoodInput(
      food: food ?? this.food,
      servingSize: servingSize ?? this.servingSize,
    );
  }
}

class ServingFormInputs {
  final String title;
  final List<ServingFoodInput> items;

  const ServingFormInputs(
      {this.title = "",
      this.items = const [
        ServingFoodInput(food: _emptyFood, servingSize: 1),
      ]});

  ServingFormInputs copyWith({String? title, List<ServingFoodInput>? items}) {
    return ServingFormInputs(
      title: title ?? this.title,
      items: items ?? this.items,
    );
  }
}

class ManageServingState {
  final ServingFormInputs formInputs;
  final bool isLoading;
  final bool createMode;
  final FoodServing? serving;
  final List<Food> foods;
  final String errorMessage;

  const ManageServingState(
      {this.formInputs = const ServingFormInputs(),
      this.isLoading = true,
      this.createMode = true,
      this.serving,
      this.foods = const [],
      this.errorMessage = ""});

  ManageServingState copyWith(
      {ServingFormInputs? formInputs,
      bool? isLoading,
      bool? createMode,
      FoodServing? serving,
      List<Food>? foods,
      String? errorMessage}) {
    return ManageServingState(
      formInputs: formInputs ?? this.formInputs,
      isLoading: isLoading ?? this.isLoading,
      createMode: createMode ?? this.createMode,
      serving: serving ?? this.serving,
      foods: foods ?? this.foods,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
