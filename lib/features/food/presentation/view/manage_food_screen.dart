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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        notif.initialLoading(widget.foodId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manageFoodProvider);

    // if createMode entries will have zero values by default...
    final initialData = state.formInputs;

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
                      const SizedBox(
                        height: 5,
                      ),
                      _FoodNameSearchField(
                        key: ValueKey("food-name-${state.inputRevision}"),
                        initialData: initialData,
                        state: state,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      DropdownButtonFormField(
                        decoration: const InputDecoration(
                          labelText: "Unit",
                          border: OutlineInputBorder(),
                        ),
                        value: initialData.unit,
                        onChanged: (unit) {
                          if (unit != null) {
                            notif.updateInputs(unit: unit);
                          }
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
                      const Divider(
                        height: 40,
                      ),
                      _showMicrosInput(initialData, state),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                            onPressed: () async {
                              if (_formKey.currentState?.validate() != true) {
                                return;
                              }

                              final success = await notif.saveFood();
                              if (!context.mounted) {
                                return;
                              }

                              if (success) {
                                Navigator.of(context).pop();
                              } else {
                                UIUtil.bottomNotifier(
                                  context: context,
                                  message: "Failed to save food item",
                                );
                              }
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _showMicrosInput(FoodFormInputs initialData, ManageFoodState state) {
    return Column(
      children: [
        Row(children: [
          // calories
          Expanded(
            child: TextFormField(
              initialValue: initialData.macros.calories.toString(),
              key: ValueKey("calories-${state.inputRevision}"),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final safeValue = double.tryParse(val);
                if (safeValue != null) {
                  final newMacro =
                      state.formInputs.macros.copyWith(calories: safeValue);
                  notif.updateInputs(macros: newMacro);
                }
              },
              decoration: const InputDecoration(
                  labelText: "Calories",
                  border: OutlineInputBorder(),
                  suffixText: "kcal"),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          // protein
          Expanded(
            child: TextFormField(
              initialValue: initialData.macros.protein.toString(),
              key: ValueKey("protein-${state.inputRevision}"),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final safeValue = double.tryParse(val);
                if (safeValue != null) {
                  final newMacro =
                      state.formInputs.macros.copyWith(protein: safeValue);
                  notif.updateInputs(macros: newMacro);
                }
              },
              decoration: const InputDecoration(
                  labelText: "Protein",
                  border: OutlineInputBorder(),
                  suffixText: "grams"),
            ),
          ),
        ]),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: initialData.macros.fats.toString(),
                key: ValueKey("fats-${state.inputRevision}"),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final safeValue = double.tryParse(val);
                  if (safeValue != null) {
                    final newMacro =
                        state.formInputs.macros.copyWith(fats: safeValue);
                    notif.updateInputs(macros: newMacro);
                  }
                },
                decoration: const InputDecoration(
                    labelText: "Fats",
                    border: OutlineInputBorder(),
                    suffixText: "grams"),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: TextFormField(
                initialValue: initialData.macros.carbs.toString(),
                key: ValueKey("carbs-${state.inputRevision}"),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final safeValue = double.tryParse(val);
                  if (safeValue != null) {
                    final newMacro =
                        state.formInputs.macros.copyWith(carbs: safeValue);
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

class _FoodNameSearchField extends ConsumerWidget {
  const _FoodNameSearchField({
    super.key,
    required this.initialData,
    required this.state,
  });

  final FoodFormInputs initialData;
  final ManageFoodState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notif = ref.read(manageFoodProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: initialData.name,
          autocorrect: true,
          enableSuggestions: true,
          onChanged: (name) {
            notif.updateInputs(name: name, clearExternalId: true);
          },
          onFieldSubmitted: (_) => notif.searchFoodSuggestions(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Please enter a food name";
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: "Food Name",
            border: const OutlineInputBorder(),
            hintText: "Food...",
            suffixIcon: IconButton(
              tooltip: "Search USDA",
              onPressed:
                  state.isSearchingFoods ? null : notif.searchFoodSuggestions,
              icon: const Icon(Icons.search),
            ),
          ),
        ),
        if (state.isSearchingFoods)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
        if (!state.isSearchingFoods && state.searchError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.searchError,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (!state.isSearchingFoods &&
            state.searchError.isEmpty &&
            state.hasSearchedFoods &&
            state.foodSuggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              "No USDA matches found.",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        if (!state.isSearchingFoods && state.foodSuggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<Food>(
            decoration: const InputDecoration(
              labelText: "USDA Matches",
              border: OutlineInputBorder(),
            ),
            isExpanded: true,
            value: null,
            items: state.foodSuggestions
                .map(
                  (food) => DropdownMenuItem(
                    value: food,
                    child: Text(
                      "${food.name} (${food.macros.calories} kcal)",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (food) {
              if (food != null) {
                notif.applyFoodSuggestion(food);
              }
            },
          ),
        ],
      ],
    );
  }
}

Map<MeasureUnit, String> _unitMap = {
  MeasureUnit.gram: 'Per 100 gram',
  MeasureUnit.milliliter: 'Per 100 milliliter',
  MeasureUnit.piece: 'Per piece'
};
