import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/food/data/repositories/food_repository_impl.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/food/domain/repositories/food_repository.dart';
import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';
import 'package:macro_diary/features/foodServing/domain/repositories/food_serving_repository.dart';

import '../../data/repositories/food_serving_repository_impl.dart';

final manageServingProvider =
    NotifierProvider.autoDispose<ManageServingNotifier, ManageServingState>(
        ManageServingNotifier.new);

class ManageServingNotifier extends AutoDisposeNotifier<ManageServingState> {
  FoodServingRepository get _repository => ref.read(servingRepositoryProvider);
  FoodRepository get _foodRepository => ref.read(foodRepositoryProvider);

  @override
  ManageServingState build() {
    return ManageServingState();
  }

  Future<void> initialLoading(String? servingId) async {
    state = state.copyWith(isLoading: true);

    try {
      final foodsFuture = _foodRepository.getAllFoods();
      final servingFuture = servingId == null || servingId.isEmpty
          ? Future<FoodServing?>.value(null)
          : _repository.getServingById(servingId);

      final serving = await servingFuture;
      final foods = await foodsFuture;
      final selectedFood = serving == null
          ? (foods.isNotEmpty ? foods.first : state.formInputs.relativeFood)
          : foods.firstWhere(
              (food) => food.id == serving.foodId,
              orElse: () => foods.isNotEmpty
                  ? foods.first
                  : state.formInputs.relativeFood,
            );

      state = state.copyWith(
        createMode: serving == null,
        serving: serving,
        foods: foods,
        formInputs: serving == null
            ? state.formInputs.copyWith(relativeFood: selectedFood)
            : ServingFormInputs(
                title: serving.label,
                servingSize: serving.servingSize,
                relativeFood: selectedFood,
              ),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> saveFoodServing() async {
    if (state.formInputs.relativeFood.id.isEmpty) return false;

    state = state.copyWith(isLoading: true);

    try {
      final serving = FoodServing(
        id: state.serving?.id ?? "",
        label: state.formInputs.title.trim(),
        foodId: state.formInputs.relativeFood.id,
        servingSize: state.formInputs.servingSize,
      );

      if (state.createMode) {
        await _repository.addServing(serving);
      } else {
        await _repository.updateServing(serving);
      }

      state = state.copyWith(serving: serving, createMode: false);
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Macros getEstimatedMacros(double servingSize, Food? selectedFood) {
    if (!state.createMode && state.serving != null) {
      // We are in edit mode...
      final tempServing = state.serving!.copyWith(servingSize: servingSize);
      return tempServing.getMacros(state.formInputs.relativeFood);
    } else if (selectedFood != null) {
      // Create temp serving...
      final tempServing = FoodServing(
          id: "",
          foodId: selectedFood.id,
          servingSize: servingSize,
          label: "Temp Label");
      return tempServing.getMacros(selectedFood);
    }
    return const Macros(protein: 0, carbs: 0, fats: 0, calories: 0);
  }

  void updateInputs({String? title, double? servingSize, Food? relativeFood}) {
    if (title == null && servingSize == null && relativeFood == null) return;

    final update = state.formInputs.copyWith(
        title: title, relativeFood: relativeFood, servingSize: servingSize);
    state = state.copyWith(formInputs: update);
  }
}

class ServingFormInputs {
  final String title;
  final double servingSize;
  final Food relativeFood;

  const ServingFormInputs(
      {this.title = "",
      this.servingSize = 1,
      this.relativeFood = const Food(
          id: "",
          name: "",
          macros: Macros(calories: 0, protein: 0, carbs: 0, fats: 0),
          unit: MeasureUnit.gram)});

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

  ManageServingState(
      {this.formInputs = const ServingFormInputs(),
      this.isLoading = false,
      this.createMode = true,
      this.serving,
      this.foods = const []});

  ManageServingState copyWith(
      {ServingFormInputs? formInputs,
      bool? isLoading,
      bool? createMode,
      FoodServing? serving,
      List<Food>? foods}) {
    return ManageServingState(
      formInputs: formInputs ?? this.formInputs,
      isLoading: isLoading ?? this.isLoading,
      createMode: createMode ?? this.createMode,
      serving: serving ?? this.serving,
      foods: foods ?? this.foods,
    );
  }
}
