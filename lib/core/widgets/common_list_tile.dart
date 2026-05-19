import 'package:flutter/material.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/core/util/prints.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/meal/domain/entities/meal.dart';

class CommonListTile extends StatelessWidget {
  const CommonListTile.food({
    super.key,
    required Food foodItem,
    required this.editFun,
    required this.addFun,
    required this.deleteFun,
  })  : _foodItem = foodItem,
        _meal = null,
        _foodsById = null;

  const CommonListTile.meal({
    super.key,
    required Meal meal,
    required Map<String, Food> foodsById,
    required this.editFun,
    required this.addFun,
    required this.deleteFun,
  })  : _foodItem = null,
        _meal = meal,
        _foodsById = foodsById;

  final Food? _foodItem;
  final Meal? _meal;
  final Map<String, Food>? _foodsById;

  final Function() editFun;
  final Function() addFun;
  final Function() deleteFun;

  bool get isMeal => _meal != null;

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
      if (isMeal) {
        macros = _meal!.getMacros(_foodsById ?? const {});
        title = _meal.label;
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
        isMeal ? Icons.dinner_dining : Icons.fastfood,
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
