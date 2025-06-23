import 'package:flutter/material.dart';
import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/features/manage_food_and_serving/view_models/manage_serving_viewmodel.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/macros.dart';
import 'package:provider/provider.dart';

class ManageServing extends StatefulWidget {
  const ManageServing({super.key, this.servingId,this.relativeFood, this.foods = const []});

  final String? servingId;
  final FoodItem? relativeFood;
  final List<FoodItem> foods;

  @override
  State<ManageServing> createState() => _ManageServingState();
}

class _ManageServingState extends State<ManageServing> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    /// Editing existing serve if serveId exists
    final serveId = widget.servingId ?? "";
    if (serveId.isNotEmpty && widget.relativeFood != null) {
      WidgetsBinding.instance.addPostFrameCallback((d) {
        final model = context.read<ManageServingViewmodel>();
        model.loadServing(serveId,widget.relativeFood!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ManageServingViewmodel>();

    String title = "";
    String servingSize = "100";
    MeasureUnit unit = MeasureUnit.gram;


    if(model.serving != null){
      title = model.serving!.label;
      servingSize = model.serving!.servingSize.toString();
      unit = model.relativeFood?.unit ?? MeasureUnit.gram;
    }

    Util.print.debug(" Serving Details are as follow : $title $servingSize $unit");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Macro Diary"),
      ),
      body: model.isLoading
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
                        initialValue: title,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Serving Title",
                            hintText: "Serving....",
                            prefixIcon: Icon(Icons.dinner_dining)),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        autocorrect: true,
                        enableSuggestions: true,
                        initialValue: servingSize,
                        decoration:  InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: "Serving Size",
                            hintText: "Amount....",
                            prefixIcon: const Icon(Icons.dinner_dining),
                            suffixText: unit.name
                        ),
                      ),
                      // _showEstimatedMacros(model.getEstimatedMacros(100, model.relativeFood)), // #TODO: get estimated macros from the form
                      const SizedBox(
                        width: 20,
                      ),
                      const Divider(
                        height: 30,
                      ),
                      (widget.relativeFood != null)?
                      _showRelativeFood(widget.relativeFood!)
                          : _showFoodSelectionMenu(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(onPressed: (){}, child: const Text("Save")),
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
        const Text("Standard Serving:",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
        ListTile(
          title: Text(food.name),
          subtitle: Text("Calories: ${food.macros.calories} | Protein: ${food.macros.protein} | Fats: ${food.macros.fats} | Carbs: ${food.macros.carbs}"),
          // isThreeLine: true,
        ),
      ],
    );
  }

  Widget _showFoodSelectionMenu(){
    return DropdownButtonFormField(
      decoration: const InputDecoration(
          label: Text("Serving of: ")
      ),
      items: widget.foods.map((e) =>DropdownMenuItem(
        value: e,
        child: Text(e.name),
      )
      ).toList(),
      onChanged: (val){},
    );
  }
}

