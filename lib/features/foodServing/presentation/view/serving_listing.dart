import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/core/widgets/common_list_tile.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/foodServing/presentation/view/manage_serving_screen.dart';
import 'package:macro_diary/features/foodServing/presentation/view_model/serving_listing_viewmodel.dart';

class ServingListing extends ConsumerWidget {
  const ServingListing({super.key, required this.addFun});

  final Function(Macros) addFun;

  void _editFood(BuildContext context, String? servingId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => ManageServing(servingId: servingId)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servingListingProvider);
    final notif = ref.watch(servingListingProvider.notifier);

    return state.when(
        data: (servings) {
          if (servings.isEmpty) {
            return UIUtil.nullScreenMsg("No food servings item added yet.");
          }

          return ListView.builder(
            itemCount: servings.length,
            itemBuilder: (ctx, count) {
              final serving = servings[count];
              if (!serving.hasAvailableFoods(notif.foodsMap)) {
                return const SizedBox();
              }

              final calculatedMacros = serving.getMacros(notif.foodsMap);
              return CommonListTile.serving(
                serving: serving,
                foodsById: notif.foodsMap,
                editFun: () => _editFood(ctx, serving.id),
                addFun: () => addFun(calculatedMacros),
                deleteFun: () {
                  notif.deleteServing(serving.id);
                },
              );
            },
          );
        },
        error: (error, stackTrace) => UIUtil.nullScreenMsg("Error: $error"),
        loading: () => UIUtil.circularLoader);
  }
}
