import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/core/util/prints.dart';
import 'package:macro_diary/features/food/data/repositories/food_repository_impl.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';

import '../../domain/repositories/food_repository.dart';

final manageFoodProvider =
    NotifierProvider.autoDispose<ManageFoodNotifier, ManageFoodState>(
  ManageFoodNotifier.new,
);

class ManageFoodNotifier extends AutoDisposeNotifier<ManageFoodState> {
  FoodRepository get _repository => ref.read(foodRepositoryProvider);

  @override
  ManageFoodState build() {
    return const ManageFoodState();
  }

  /// Load Food item if editing
  Future<void> initialLoading(String? foodId) async {
    if (foodId == null || foodId.isEmpty) return;

    state = state.copyWith(isLoading: true);

    try {
      var tempFood = await _repository.getFoodById(foodId);
      if (tempFood == null) {
        state = state.copyWith(createMode: true);
        return;
      } else {
        Print.debug("Initial Data in food viewModel is ${tempFood.toString()}");

        state = state.copyWith(
          createMode: false,
          food: tempFood,
          formInputs: FoodFormInputs(
            name: tempFood.name,
            unit: tempFood.unit,
            macros: tempFood.macros,
            externalId: tempFood.externalId,
          ),
          inputRevision: state.inputRevision + 1,
        );
      }
    } catch (e) {
      Print.error("Failed initialLoading");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Save – create or update based on presence of an ID
  Future<bool> saveFood() async {
    state = state.copyWith(isLoading: true);

    try {
      Print.debug("Info for saving food is: ${state.formInputs.toString()}");

      final foodItem = Food(
        name: state.formInputs.name,
        unit: state.formInputs.unit,
        macros: state.formInputs.macros,
        id: state.createMode ? "" : state.food?.id ?? "",
        externalId: state.formInputs.externalId,
      );

      if (state.createMode) {
        await _repository.addFood(foodItem);
      } else {
        await _repository.updateFood(foodItem);
      }
      return true;
    } catch (e) {
      Print.error("Failed to save food Item");
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Updates any change made in inputs
  void updateInputs({
    Macros? macros,
    MeasureUnit? unit,
    String? name,
    String? externalId,
    bool clearExternalId = false,
  }) {
    if (macros == null &&
        unit == null &&
        name == null &&
        externalId == null &&
        !clearExternalId) {
      return;
    }

    final newInputs = state.formInputs.copyWith(
      macros: macros,
      unit: unit,
      name: name,
      externalId: externalId,
      clearExternalId: clearExternalId,
    );
    state = state.copyWith(
      formInputs: newInputs,
      foodSuggestions: name == null ? state.foodSuggestions : const [],
      hasSearchedFoods: name == null ? state.hasSearchedFoods : false,
      searchError: name == null ? state.searchError : "",
    );
  }

  void applyFoodSuggestion(Food food) {
    state = state.copyWith(
      formInputs: FoodFormInputs(
        name: food.name,
        unit: food.unit,
        macros: food.macros,
        externalId: food.externalId,
      ),
      foodSuggestions: const [],
      hasSearchedFoods: false,
      searchError: "",
      inputRevision: state.inputRevision + 1,
    );
  }

  /// Search food macros in USDA DB
  Future<void> searchFoodSuggestions() async {
    final query = state.formInputs.name.trim();
    if (query.length <= 2) {
      state = state.copyWith(
        foodSuggestions: const [],
        hasSearchedFoods: true,
        isSearchingFoods: false,
        searchError: "Enter at least 3 characters to search USDA.",
      );
      return;
    }

    state = state.copyWith(
      isSearchingFoods: true,
      hasSearchedFoods: true,
      foodSuggestions: const [],
      searchError: "",
    );

    try {
      final foods = await _repository.searchFoods(query);
      if (state.formInputs.name.trim() != query) {
        state = state.copyWith(isSearchingFoods: false);
        return;
      }

      state = state.copyWith(
        foodSuggestions: foods,
        isSearchingFoods: false,
        searchError: "",
      );
    } catch (e) {
      Print.error("Failed to fetch USDA suggestions with error : ${e}");
      state = state.copyWith(
        foodSuggestions: const [],
        isSearchingFoods: false,
        searchError: "Could not load USDA suggestions.",
      );
    }
  }
}

class FoodFormInputs {
  final String name;
  final MeasureUnit unit;
  final Macros macros;
  final String? externalId;

  const FoodFormInputs({
    this.name = "",
    this.unit = MeasureUnit.gram,
    this.macros = const Macros(calories: 0, protein: 0, carbs: 0, fats: 0),
    this.externalId,
  });

  FoodFormInputs copyWith({
    String? name,
    MeasureUnit? unit,
    Macros? macros,
    String? externalId,
    bool clearExternalId = false,
  }) {
    return FoodFormInputs(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      macros: macros ?? this.macros,
      externalId: clearExternalId ? null : externalId ?? this.externalId,
    );
  }

  @override
  String toString() {
    return 'FormImputs{name: $name, unit: $unit, macros: $macros}';
  }
}

class ManageFoodState {
  final FoodFormInputs formInputs;
  final bool isLoading;
  final bool createMode;
  final Food? food;
  final int inputRevision;
  final List<Food> foodSuggestions;
  final bool isSearchingFoods;
  final bool hasSearchedFoods;
  final String searchError;

  const ManageFoodState({
    this.formInputs = const FoodFormInputs(),
    this.isLoading = false,
    this.createMode = true,
    this.food,
    this.inputRevision = 0,
    this.foodSuggestions = const [],
    this.isSearchingFoods = false,
    this.hasSearchedFoods = false,
    this.searchError = "",
  });

  ManageFoodState copyWith({
    FoodFormInputs? formInputs,
    bool? isLoading,
    bool? createMode,
    Food? food,
    int? inputRevision,
    List<Food>? foodSuggestions,
    bool? isSearchingFoods,
    bool? hasSearchedFoods,
    String? searchError,
  }) {
    return ManageFoodState(
      formInputs: formInputs ?? this.formInputs,
      isLoading: isLoading ?? this.isLoading,
      createMode: createMode ?? this.createMode,
      food: food ?? this.food,
      inputRevision: inputRevision ?? this.inputRevision,
      foodSuggestions: foodSuggestions ?? this.foodSuggestions,
      isSearchingFoods: isSearchingFoods ?? this.isSearchingFoods,
      hasSearchedFoods: hasSearchedFoods ?? this.hasSearchedFoods,
      searchError: searchError ?? this.searchError,
    );
  }
}
