
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/core/widgets/common_list_tile.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/food/presentation/view/manage_food_screen.dart';
import 'package:macro_diary/features/food/presentation/view_model/food_listing_viewmodel.dart';

class FoodListing extends ConsumerWidget {
  const FoodListing({super.key, required this.addFun});

  final Function(Macros) addFun;

  void _editFood(BuildContext context, String? foodId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => ManageFood(foodId: foodId)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. watch the provider. 'state' is now an AsyncValue<List<Food>>
    final state = ref.watch(foodListProvider);

    // 2. Use .when to handle all 3 possible states
    return state.when(
      // Data state: The Future resolved successfully
      data: (foods) {
        if (foods.isEmpty) {
          return UIUtil.nullScreenMsg("No food item added yet.");
        }

        return ListView.builder(
          itemCount: foods.length,
          itemBuilder: (ctx, count) {
            final food = foods[count];
            return CommonListTile(
              foodItem: food,
              editFun: () => _editFood(ctx, food.id),
              addFun: () => addFun(food.macros),
              deleteFun: () {
                // Access the notifier to call your methods
                ref.read(foodListProvider.notifier).deleteFood(food.id);
              },
            );
          },
        );
      },
      // Loading state: The 'build()' method in your notifier is currently running
      loading: () => const Center(child: CircularProgressIndicator()),
      // Error state: Something went wrong in the repository or build method
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}