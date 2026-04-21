

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/core/util/prints.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/food_repository.dart';

const uuid = Uuid();


class FoodFormInputs {
  final String name;
  final MeasureUnit unit;
  final Macros macros;

  const FoodFormInputs({
    this.name = "",
    this.unit = MeasureUnit.gram,
    this.macros = const Macros(calories: 0, protein: 0, carbs: 0, fats: 0),
  });

  FoodFormInputs copyWith({
    String? name,
    MeasureUnit? unit,
    Macros? macros,
  }) {
    return FoodFormInputs(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      macros: macros ?? this.macros,
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

  const ManageFoodState({
    this.formInputs = const FoodFormInputs(),
    this.isLoading = false,
    this.createMode = true,
    this.food,
  });

  ManageFoodState copyWith({
    FoodFormInputs? formInputs,
    bool? isLoading,
    bool? createMode,
    Food? food,
  }) {
    return ManageFoodState(
      formInputs: formInputs ?? this.formInputs,
      isLoading: isLoading ?? this.isLoading,
      createMode: createMode ?? this.createMode,
      food: food ?? this.food,
    );
  }
}

class ManageFoodNotifier extends Notifier<ManageFoodState>{
  final FoodRepository _repository;

  ManageFoodNotifier(this._repository);

  @override
  ManageFoodState build() {
    return const ManageFoodState();
  }


  /// Load Food item if editing
  Future<void> initialLoading(String? foodId) async {
    if (foodId == null || foodId.isEmpty) return;

    state = state.copyWith(isLoading: true);

    try{
      var tempFood = await _repository.getFoodById(foodId);
      if(tempFood==null){
        state = state.copyWith(createMode: true);
        return;
      }else{
        Print.debug("Initial Data in food viewModel is ${tempFood.toString()}");

        state = state.copyWith(createMode: false, food: tempFood, formInputs: FoodFormInputs(
            name: tempFood.name,
            unit: tempFood.unit,
            macros: tempFood.macros
        ));
      }

    }catch(e){
      Print.error("Failed initialLoading");
    }finally{
      state = state.copyWith(isLoading: false);
    }
  }

  /// 2. Save – create or update based on presence of an ID
  Future<void> saveFood({Function()? callback}) async {
    state = state.copyWith(isLoading: true);

    try{
      Print.debug("Info for saving food is: ${state.formInputs.toString()}");

      final foodItem = Food(
        name: state.formInputs.name,
        unit: state.formInputs.unit,
        macros: state.formInputs.macros,
        id: "",
      );

      _repository.addFood(foodItem);

    }catch(e){
      Print.error("Failed to save food Item");
    }finally{
      state = state.copyWith(isLoading: false);
      callback?.call(); // call the callback if any
    }
  }
  
}