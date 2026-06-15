import 'package:flutter/material.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';

class OneTimeMacrosInput extends StatefulWidget {
  const OneTimeMacrosInput({
    super.key,
    required this.saveMacrosFunc,
  });

  final Future<void> Function(Macros macros) saveMacrosFunc;

  @override
  State<OneTimeMacrosInput> createState() => _OneTimeMacrosInputState();
}

class _OneTimeMacrosInputState extends State<OneTimeMacrosInput> {
  double _calories = 0;
  double _protein = 0;
  double _fats = 0;
  double _carbs = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextFormField(
                initialValue: _calories.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  _calories = double.tryParse(val) ?? _calories;
                },
                decoration: const InputDecoration(
                  labelText: "Calories",
                  border: OutlineInputBorder(),
                  suffixText: "kcal",
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _protein.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  _protein = double.tryParse(val) ?? _protein;
                },
                decoration: const InputDecoration(
                  labelText: "Protein",
                  border: OutlineInputBorder(),
                  suffixText: "grams",
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _fats.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  _fats = double.tryParse(val) ?? _fats;
                },
                decoration: const InputDecoration(
                  labelText: "Fats",
                  border: OutlineInputBorder(),
                  suffixText: "grams",
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _carbs.toString(),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  _carbs = double.tryParse(val) ?? _carbs;
                },
                decoration: const InputDecoration(
                  labelText: "Carbohydrates",
                  border: OutlineInputBorder(),
                  suffixText: "grams",
                ),
              ),
              const SizedBox(height: 10),
              Align(
                heightFactor: 1,
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () async {
                    await widget.saveMacrosFunc(
                      Macros(
                        calories: _calories,
                        protein: _protein,
                        carbs: _carbs,
                        fats: _fats,
                      ),
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
