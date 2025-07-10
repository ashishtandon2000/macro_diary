
import 'package:flutter/material.dart';
import 'package:macro_diary/models/macros.dart';

class OneTimeMacrosInput extends StatelessWidget {
  OneTimeMacrosInput({super.key, required this.saveMacrosFunc});

  final Function(Macros macros) saveMacrosFunc;
  final macros = Macros(calories: 0, protein: 0, carbs: 0, fats: 0);


  @override
  Widget build(BuildContext context){
    return Material(
      child: Padding(
        padding: const EdgeInsetsGeometry.all(30),
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children:  [
              // calories
              TextFormField(
                initialValue: macros.calories.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final safeValue = int.tryParse(val);
                  if(safeValue!= null){
                    macros.calories = safeValue;
                  }
                },
                decoration: const InputDecoration(
                    labelText: "Calories",
                    border: OutlineInputBorder(),
                    suffixText: "kcal"),
              ),
              TextFormField(
                initialValue: macros.protein.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final safeValue = double.tryParse(val);
                  if(safeValue!= null){
                    macros.protein = safeValue;
                  }
                },
                decoration: const InputDecoration(
                    labelText: "Protein",
                    border: OutlineInputBorder(),
                    suffixText: "grams"),
              ),
              TextFormField(
                initialValue: macros.fats.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final safeValue = double.tryParse(val);
                  if(safeValue!= null){
                    macros.fats = safeValue;
                  }
                },
                decoration: const InputDecoration(
                    labelText: "Fats",
                    border: OutlineInputBorder(),
                    suffixText: "grams"),
              ),
              TextFormField(
                initialValue: macros.carbs.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final safeValue = double.tryParse(val);
                  if(safeValue!= null){
                    macros.carbs = safeValue;
                  }
                },
                decoration: const InputDecoration(
                    labelText: "Carbohydrates",
                    border: OutlineInputBorder(),
                    suffixText: "grams"),
              ),
              Align(
                heightFactor: 1,
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                    onPressed: (){
                      saveMacrosFunc(macros);
                      Navigator.of(context).pop();
                    }, child: const Text("Save")),
              )
            ],
          ),
        ),
      ),
    );
  }
}