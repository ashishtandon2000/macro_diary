import 'package:flutter/material.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/core/util/prints.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/foodServing/domain/entities/food_serving.dart';

class CommonListTile extends StatelessWidget {
  const CommonListTile.food({
    super.key,
    required Food foodItem,
    required this.editFun,
    required this.addFun,
    required this.deleteFun,
  })  : _foodItem = foodItem,
        _serving = null,
        _foodsById = null;

  const CommonListTile.serving({
    super.key,
    required FoodServing serving,
    required Map<String, Food> foodsById,
    required this.editFun,
    required this.addFun,
    required this.deleteFun,
  })  : _foodItem = null,
        _serving = serving,
        _foodsById = foodsById;

  final Food? _foodItem;
  final FoodServing? _serving;
  final Map<String, Food>? _foodsById;

  final Function() editFun;
  final Function() addFun;
  final Function() deleteFun;

  bool get isServing => _serving != null;

  @override
  Widget build(BuildContext context) {
    String title = "";

    Macros macros = const Macros(
      calories: 0,
      protein: 0,
      fats: 0,
      carbs: 0,
    );

    try {
      if (isServing) {
        macros = _serving!.getMacros(_foodsById ?? const {});
        title = _serving.label;
      } else {
        macros = _foodItem!.macros;
        title = _foodItem.name;
      }
    } catch (e) {
      Print.error("CommonListTile >> failed to load detail with error: $e");
    } finally {
      Print.debug("#ONETIME macros for $title: $macros");
    }

    return ListTile(
      leading: Icon(
        isServing ? Icons.dinner_dining : Icons.fastfood,
      ),
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
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
