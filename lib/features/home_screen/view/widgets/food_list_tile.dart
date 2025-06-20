

import 'package:flutter/material.dart';
import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/models/food_serving.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/summary.dart';

class FoodListTile extends StatelessWidget{
  const FoodListTile({required this.foodItem, this.serving,super.key,required this.editFun, required this.addFun});

  final FoodItem foodItem;
  final FoodServing? serving;
  final Function() editFun;
  final Function() addFun;

  @override
  Widget build(BuildContext context){

    String title = "";
    Macros macros = Macros(calories: 0, protein: 0, fats: 0, carbs: 0);

      try{
        if(serving !=null) { // Case of serving and foodItem is related to serving
          macros = serving!.getMacros(foodItem);
          title = serving!.label;
        }else{
          macros = foodItem.macros;
          title = foodItem.name;
        }
      }catch(e){
        Util.print.error("FoodListTile >> failed to load detail with error:  $e");
      }


    return ListTile(
      leading: Icon((serving != null)?Icons.dinner_dining:Icons.fastfood),
      title: Text(title),
      subtitle: Text("Calories: ${macros.calories} | Protein: ${macros.protein} | Fats: ${macros.fats} | Carbs: ${macros.carbs}"),
      onTap: editFun,
      trailing: IconButton(onPressed: addFun, icon: const Icon(Icons.add)),
      // isThreeLine: true,
    );
  }
}