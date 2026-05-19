import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/core/widgets/common_list_tile.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/meal/presentation/view/manage_meal_screen.dart';
import 'package:macro_diary/features/meal/presentation/view_model/meal_listing_viewmodel.dart';

class MealListing extends ConsumerWidget {
  const MealListing({super.key, required this.addFun});

  final Function(Macros) addFun;

  void _editMeal(BuildContext context, String? mealId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => ManageMeal(mealId: mealId)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mealListingProvider);
    final notif = ref.watch(mealListingProvider.notifier);

    return state.when(
        data: (meals) {
          if (meals.isEmpty) {
            return UIUtil.nullScreenMsg("No meals added yet.");
          }

          return ListView.builder(
            itemCount: meals.length,
            itemBuilder: (ctx, count) {
              final meal = meals[count];
              if (!meal.hasAvailableFoods(notif.foodsMap)) {
                return const SizedBox();
              }

              final calculatedMacros = meal.getMacros(notif.foodsMap);
              return CommonListTile.meal(
                meal: meal,
                foodsById: notif.foodsMap,
                editFun: () => _editMeal(ctx, meal.id),
                addFun: () => addFun(calculatedMacros),
                deleteFun: () {
                  notif.deleteMeal(meal.id);
                },
              );
            },
          );
        },
        error: (error, stackTrace) => UIUtil.nullScreenMsg("Error: $error"),
        loading: () => UIUtil.circularLoader);
  }
}
