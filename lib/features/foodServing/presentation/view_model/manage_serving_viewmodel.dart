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
      final selectedFood = serving == null
          ? (foods.isNotEmpty ? foods.first : _emptyFood)
          : _findFoodById(foods, serving.foodId) ?? _emptyFood;

      String errorMessage = "";
      if (foods.isEmpty) {
        errorMessage = "Add a food item before creating a serving.";
      } else if (isEditing && serving == null) {
        errorMessage = "Serving not found.";
      } else if (serving != null && selectedFood.id.isEmpty) {
        errorMessage = "The food item for this serving is no longer available.";
      }

      state = state.copyWith(
        createMode: serving == null,
        serving: serving,
        foods: foods,
        errorMessage: errorMessage,
        formInputs: serving == null
            ? state.formInputs.copyWith(relativeFood: selectedFood)
            : ServingFormInputs(
                title: serving.label,
                servingSize: serving.servingSize,
                relativeFood: selectedFood,
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
        foodId: state.formInputs.relativeFood.id,
        servingSize: state.formInputs.servingSize,
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
            servingSize: savedServing.servingSize,
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

  Macros getEstimatedMacros(double servingSize, Food? selectedFood) {
    final food = selectedFood ?? state.formInputs.relativeFood;
    if (food.id.isEmpty || servingSize <= 0 || !servingSize.isFinite) {
      return _emptyMacros;
    }

    final tempServing = FoodServing(
      id: "",
      foodId: food.id,
      servingSize: servingSize,
      label: "Temp Label",
    );
    return tempServing.getMacros(food);
  }

  void updateInputs({String? title, double? servingSize, Food? relativeFood}) {
    if (title == null && servingSize == null && relativeFood == null) return;

    final update = state.formInputs.copyWith(
        title: title, relativeFood: relativeFood, servingSize: servingSize);
    state = state.copyWith(formInputs: update, errorMessage: "");
  }

  String? _validationMessage() {
    if (state.formInputs.title.trim().isEmpty) {
      return "Please enter a serving title.";
    }
    if (state.formInputs.servingSize <= 0 ||
        !state.formInputs.servingSize.isFinite) {
      return "Serving size must be greater than zero.";
    }
    if (state.formInputs.relativeFood.id.isEmpty) {
      return "Please select a food item for this serving.";
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

class ServingFormInputs {
  final String title;
  final double servingSize;
  final Food relativeFood;

  const ServingFormInputs(
      {this.title = "", this.servingSize = 1, this.relativeFood = _emptyFood});

  ServingFormInputs copyWith(
      {String? title, double? servingSize, Food? relativeFood}) {
    return ServingFormInputs(
        title: title ?? this.title,
        servingSize: servingSize ?? this.servingSize,
        relativeFood: relativeFood ?? this.relativeFood);
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
