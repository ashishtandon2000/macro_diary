import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';

final manageServingProvider = NotifierProvider.autoDispose<ManageServingNotifier, ManageServingState>(ManageServingNotifier.new);

class ManageServingNotifier extends AutoDisposeNotifier<ManageServingState>{

  @override
  ManageServingState build() {
    return ManageServingState();
  }

  void initialLoading(){
    /// TODO: Fetch serving, load all food items
  }

  Future<bool> saveFoodServing()async{
    /// TODO: Implement this
    ///
    return true;
  }


  Macros getEstimatedMacros(double servingSize, Food? selectedFood){
    if(!state.createMode && state.serving!=null){// We are in edit mode...
      final tempServing = state.serving!.copyWith(servingSize: servingSize);
      return tempServing.getMacros(state.formInputs.relativeFood);
    }else if(selectedFood != null){ // Create temp serving...
      final tempServing = FoodServing(id: "", foodId: selectedFood.id, servingSize: servingSize,label: "Temp Label");
      return tempServing.getMacros(selectedFood);
    }
    return const Macros(protein: 0, carbs: 0, fats: 0, calories: 0);
  }

  void updateInputs({String? title, double? servingSize,Food? relativeFood}){
    if(title == null && servingSize == null && relativeFood == null) return;

    final update = state.formInputs.copyWith(
        title: title,
        relativeFood: relativeFood,
        servingSize: servingSize
    );
    state.copyWith(formInputs: update);
  }
}

class ServingFormInputs {
  final String title;
  final double servingSize;
  final Food relativeFood;

  const ServingFormInputs({this.title = "", this.servingSize = 1, this.relativeFood = const Food(id: "", name: "", macros: Macros(calories: 0, protein: 0, carbs: 0, fats: 0), unit: MeasureUnit.gram)});

  ServingFormInputs copyWith({String? title, double? servingSize,Food? relativeFood}){
    return ServingFormInputs(
      title: title??this.title,
      servingSize: servingSize??this.servingSize,
      relativeFood: relativeFood??this.relativeFood
    );
  }
}

class ManageServingState {
  final ServingFormInputs formInputs;
  final bool isLoading;
  final bool createMode;
  final FoodServing? serving;
  final List<Food> foods;

  ManageServingState({
    this.formInputs = const ServingFormInputs(),
    this.isLoading = false,
    this.createMode = true,
    this.serving,
    this.foods = const []
  });

  ManageServingState copyWith({ServingFormInputs? formInputs,bool? isLoading, bool? createMode,FoodServing? serving, List<Food>? foods}){
    return ManageServingState(
      formInputs: formInputs??this.formInputs,
      isLoading: isLoading?? this.isLoading,
      createMode: createMode??this.createMode,
      serving: serving??this.serving,
      foods:foods??this.foods,
    );
  }
}