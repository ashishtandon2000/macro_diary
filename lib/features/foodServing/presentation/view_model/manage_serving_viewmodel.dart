import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';


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

  ManageServingState({
    this.formInputs = const ServingFormInputs(),
    this.isLoading = false,
    this.createMode = true,
    this.serving
  });

  ManageServingState copyWith({ServingFormInputs? formInputs,bool? isLoading, bool? createMode,FoodServing? serving}){
    return ManageServingState(
      formInputs: formInputs??this.formInputs,
      isLoading: isLoading?? this.isLoading,
      createMode: createMode??this.createMode,
      serving: serving??this.serving
    );
  }
}