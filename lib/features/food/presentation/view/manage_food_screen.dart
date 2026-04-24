import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';

import '../view_model/manage_food_viewmodel.dart';

// TODO: Implement riverpod | refactor code


class ManageFood extends ConsumerStatefulWidget {
  /// Screen to handle: create or edit food entry
  const ManageFood({super.key, this.foodId});

  final String? foodId;

  @override
  ConsumerState<ManageFood> createState() => _ManageFoodState();
}

class _ManageFoodState extends ConsumerState<ManageFood> {
  final _formKey = GlobalKey<FormState>();
  late final ManageFoodNotifier notif;
  @override
  void initState() {
    super.initState();
    notif = ref.read(manageFoodProvider.notifier);

    notif.initialLoading(widget.foodId);
  }


  @override
  Widget build(BuildContext context) {

    final state = ref.watch(manageFoodProvider);

    // if createMode entries will have zero values by default...
    var initialData =  state.formInputs;

    return Scaffold(
      appBar: AppBar(
        title: Text((state.createMode) ? "Create Food" : "Edit Food"),
      ),
      body: state.isLoading
          ? UIUtil.circularLoader
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
                    notif.updateInputs(name: name);
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
                    if (unit != null) notif.updateInputs(unit: unit);
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
                _showMicrosInput(initialData,state),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                        onPressed:(){
                          notif.saveFood(
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

  Widget _showMicrosInput(FoodFormInputs initialData, ManageFoodState state){
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
                    final safeValue = double.tryParse(val);
                    if(safeValue!= null){
                      final newMacro = state.formInputs.macros.copyWith(calories: safeValue);
                      notif.updateInputs(macros: newMacro);
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
                      final newMacro = state.formInputs.macros.copyWith(protein: safeValue);
                      notif.updateInputs(macros: newMacro);
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
                    final newMacro = state.formInputs.macros.copyWith(fats: safeValue);
                    notif.updateInputs(macros: newMacro);
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
                    final newMacro = state.formInputs.macros.copyWith(carbs: safeValue);
                    notif.updateInputs(macros: newMacro);
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

Map<MeasureUnit, String> _unitMap = {
  MeasureUnit.gram: 'Per 100 gram',
  MeasureUnit.milliliter: 'Per 100 milliliter',
  MeasureUnit.piece: 'Per piece'
};
