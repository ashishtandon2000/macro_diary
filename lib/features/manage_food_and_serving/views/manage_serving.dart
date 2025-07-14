import 'package:flutter/material.dart';
import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/features/manage_food_and_serving/view_models/manage_serving_viewmodel.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/macros.dart';
import 'package:provider/provider.dart';

class ManageServing extends StatelessWidget {
  ManageServing({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final mv = context.watch<ManageServingViewmodel>();

    var initialData =  mv.formImputs;



    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Serving"),
      ),
      body: mv.isLoading
          ? Util.wCircularLoader
          : Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        autocorrect: true,
                        enableSuggestions: true,
                        initialValue: initialData.title,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Serving Title",
                            hintText: "Serving....",
                            prefixIcon: Icon(Icons.dinner_dining)),
                          onChanged: (t) {
                            initialData.title = t;
                          }
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        autocorrect: true,
                        enableSuggestions: true,
                        initialValue: initialData.servingSize.toString(),
                        decoration:  InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: "Serving Size",
                            hintText: "Amount....",
                            prefixIcon: const Icon(Icons.dinner_dining),
                            suffixText: mv.formImputs.relativeFood.unit.name,
                        ),
                        onChanged: (amount){
                          final safeValue = int.tryParse(amount);
                          if(safeValue!= null){
                            mv.formImputs.servingSize = safeValue;
                          }
                        },
                      ),
                      // _showEstimatedMacros(model.getEstimatedMacros(100, model.relativeFood)), // #TODO: get estimated macros from the form
                      const SizedBox(
                        width: 20,
                      ),
                      const Divider(
                        height: 30,
                      ),
                      (mv.createMode)?
                          _showFoodSelectionMenu(context):
                      _showRelativeFood(mv.formImputs.relativeFood),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(onPressed: (){
                            mv.saveServing(callback: ()=>Navigator.of(context).pop()
                            );
                          }, child: const Text("Save")),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _showEstimatedMacros(Macros macros){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Custom Serving Contain:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
        ListTile(
          subtitle: Text("Calories: ${macros.calories} | Protein: ${macros.protein} | Fats: ${macros.fats} | Carbs: ${macros.carbs}"),
          // isThreeLine: true,
        ),
      ],
    );
  }

  Widget _showRelativeFood(FoodItem food){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Serving of:",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
        ListTile(
          title: Text(food.name),
          subtitle: Text("Calories: ${food.macros.calories} | Protein: ${food.macros.protein} | Fats: ${food.macros.fats} | Carbs: ${food.macros.carbs}"),
          // isThreeLine: true,
        ),
      ],
    );
  }

  Widget _showFoodSelectionMenu(BuildContext ctx){
    final mv = ctx.read<ManageServingViewmodel>();

    return DropdownButtonFormField(
      decoration: const InputDecoration(
          label: Text("Serving of: ")
      ),
      items: mv.foods.map((e) =>DropdownMenuItem(
        value: e,
        child: Text(e.name),
      )
      ).toList(),
      onChanged: (food){
        if(food != null){
          mv.updateSelectedFood(food);
        }
      },
    );
  }
}

