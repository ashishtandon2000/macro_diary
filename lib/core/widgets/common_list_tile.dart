import 'package:flutter/material.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/core/util/prints.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';

class CommonListTile extends StatelessWidget {
  const CommonListTile({
    required this.foodItem,
    super.key,
    required this.editFun,
    required this.addFun,
    required this.deleteFun,
  });

  final Food foodItem;
  final VoidCallback editFun;
  final VoidCallback addFun;
  final VoidCallback deleteFun;

  @override
  Widget build(BuildContext context) {
    final Macros macros = foodItem.macros;
    final String title = foodItem.name;

    Print.debug("#ONETIME macros for $title: $macros");

    return ListTile(
      leading: const Icon(Icons.fastfood),
      title: Text(title),
      subtitle: Text(
        "Calories: ${macros.calories} | "
            "Protein: ${macros.protein} | "
            "Fats: ${macros.fats} | "
            "Carbs: ${macros.carbs}",
      ),
      onTap: addFun,
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'edit') {
            editFun();
          } else if (value == 'delete') {
            final confirmed = await UIUtil.confirmationDialog(
              context,
              title: "Delete Item",
              msg: "Are you sure you want to delete this item?",
            );
            if (confirmed == true) {
              deleteFun();
            }
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}

//
// class CommonListTile extends StatelessWidget{
//   const CommonListTile({required this.foodItem, this.serving,super.key,required this.editFun, required this.addFun, required this.deleteFun});
//
//   final Food foodItem;
//   final FoodServing? serving;
//   final Function() editFun;
//   final Function() addFun;
//   final Function() deleteFun;
//
//   @override
//   Widget build(BuildContext context){
//
//     String title = "";
//     Macros macros = const Macros(calories: 0, protein: 0, fats: 0, carbs: 0);
//
//     try{
//       if(serving !=null) { // Case of serving and foodItem is related to serving
//         macros = serving!.getMacros(foodItem);
//         title = serving!.label;
//       }else{
//         macros = foodItem.macros;
//         title = foodItem.name;
//       }
//     }catch(e){
//       Print.error("CommonListTile >> failed to load detail with error:  $e");
//     }finally{
//       Print.debug("#ONETIME macros for $title: $macros");
//     }
//
//
//     return ListTile(
//       leading: Icon((serving != null)?Icons.dinner_dining:Icons.fastfood),
//       title: Text(title),
//       subtitle: Text("Calories: ${macros.calories} | Protein: ${macros.protein} | Fats: ${macros.fats} | Carbs: ${macros.carbs}"),
//       onTap: addFun,
//       trailing: PopupMenuButton<String>(
//         onSelected: (value)async{
//           if (value == 'edit') {
//             editFun();
//           } else if (value == 'delete') {
//             final confirmed = await Util.wConfirmationDialog(
//                 context,
//                 title: "Delete Item",
//                 msg: "Are you sure you want to delete this item?"
//             );
//             if(confirmed == true){
//               deleteFun();
//             }
//           }
//         },
//         itemBuilder: (context) => [
//           const PopupMenuItem(value: 'edit', child: Text('Edit')),
//           const PopupMenuItem(value: 'delete', child: Text('Delete')),
//         ],
//       ),
//       // isThreeLine: true,
//     );
//   }
// }