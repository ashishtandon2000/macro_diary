
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

  void _editFood(BuildContext context,String? foodId){
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>ManageFood(foodId: foodId,)));
  }

  @override
  Widget build(BuildContext context, ref){

    final state = ref.watch(foodListProvider);
    final notif = ref.read(foodListProvider.notifier);
    if(state.foods.isEmpty){
      return UIUtil.nullScreenMsg("No food item added yet.");
    }

    return ListView.builder(
      itemCount: state.foods.length,
        itemBuilder: (ctx, count){
        final food = state.foods[count];
          return CommonListTile(
              foodItem: food,
              editFun: (){
                _editFood(ctx,food.id);
              },
              addFun: (){
                addFun(food.macros);
                //   TODO: implement this
              },
              deleteFun: (){
                notif.deleteFood(food.id);
              });
        });
  }
}