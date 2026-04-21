import 'package:flutter/material.dart';

// TODO: Implement riverpod | refactor code


class ManageFood extends StatelessWidget {
  /// Create or edit food entry
  ManageFood({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final mv = context.watch<ManageFoodViewmodel>();

    // if createMode entries will have zero values by default...
    var initialData =  mv.formImputs;

    return Scaffold(
      appBar: AppBar(
        title: Text((mv.createMode) ? "Create Food" : "Edit Food"),
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
              children: [
                const SizedBox(height: 5,),
                TextFormField(
                  initialValue: initialData.name,
                  autocorrect: true,
                  enableSuggestions: true,
                  onChanged: (name) {
                    mv.formImputs.name = name;
                  },
                  decoration: const InputDecoration(
                      labelText: "Food Name",
                      border: OutlineInputBorder(),
                      hintText: "Food..."),
                ),
                const SizedBox(height: 20,),
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: "Unit",
                    border: OutlineInputBorder(),
                  ),
                  value: initialData.unit,
                  onChanged: (unit) {
                    if (unit != null) mv.formImputs.unit = unit;
                  },
                  items: MeasureUnit.values
                      .map(
                        (unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(_unitMap[unit] ?? "Standard Unit"),
                    ),
                  )
                      .toList(),
                ),
                const Divider(height: 40,),
                _showMicrosInput(initialData,mv),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                        onPressed:(){
                          mv.saveFood(
                              callback: ()=> Navigator.of(context).pop()
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

  Widget _showMicrosInput(FoodFormImputs initialData, ManageFoodViewmodel mv){
    return Column(

      children: [
        Row(
            children: [
              // calories
              Expanded(
                child: TextFormField(
                  initialValue: initialData.macros.calories.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final safeValue = int.tryParse(val);
                    if(safeValue!= null){
                      mv.formImputs.macros.calories = safeValue;
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: "Calories",
                      border: OutlineInputBorder(),
                      suffixText: "kcal"),
                ),
              ),
              const SizedBox(width: 20,),
              // protein
              Expanded(
                child: TextFormField(
                  initialValue: initialData.macros.protein.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final safeValue = double.tryParse(val);
                    if(safeValue!= null){
                      mv.formImputs.macros.protein = safeValue;
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: "Protein",
                      border: OutlineInputBorder(),
                      suffixText: "grams"),
                ),
              ),
            ]

        ),
        const SizedBox(height: 20,),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: initialData.macros.fats.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final safeValue = double.tryParse(val);
                  if(safeValue!= null){
                    mv.formImputs.macros.fats = safeValue;
                  }
                },
                decoration: const InputDecoration(
                    labelText: "Fats",
                    border: OutlineInputBorder(),
                    suffixText: "grams"),
              ),
            ),
            const SizedBox(width: 20,),
            Expanded(
              child: TextFormField(
                initialValue: initialData.macros.carbs.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final safeValue = double.tryParse(val);
                  if(safeValue!= null){
                    mv.formImputs.macros.carbs = safeValue;
                  }
                },
                decoration: const InputDecoration(
                    labelText: "Carbohydrates",
                    border: OutlineInputBorder(),
                    suffixText: "grams"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}