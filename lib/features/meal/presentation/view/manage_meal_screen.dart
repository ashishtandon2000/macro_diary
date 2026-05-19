import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/meal/presentation/view_model/manage_meal_viewmodel.dart';

class ManageMeal extends ConsumerStatefulWidget {
  const ManageMeal({super.key, this.mealId});

  final String? mealId;

  @override
  ConsumerState<ManageMeal> createState() => _ManageMeal();
}

class _ManageMeal extends ConsumerState<ManageMeal> {
  final _formKey = GlobalKey<FormState>();
  late final ManageMealNotifier notif;

  @override
  void initState() {
    super.initState();
    notif = ref.read(manageMealProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        notif.initialLoading(widget.mealId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manageMealProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text((state.createMode) ? "Create Meal" : "Update Meal")),
      body: state.isLoading
          ? UIUtil.circularLoader
          : Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (state.errorMessage.isNotEmpty) ...[
                        _showErrorMessage(context, state.errorMessage),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                          autocorrect: true,
                          enableSuggestions: true,
                          initialValue: state.formInputs.title,
                          validator: (title) {
                            if (title == null || title.trim().isEmpty) {
                              return "Please enter a meal title";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Meal Title",
                              hintText: "Meal name",
                              prefixIcon: Icon(Icons.dinner_dining)),
                          onChanged: (t) {
                            notif.updateInputs(title: t);
                          }),
                      const SizedBox(height: 20),
                      const _MealItemsEditor(),
                      const SizedBox(height: 12),
                      _showEstimatedMacros(notif.getEstimatedMacros()),
                      const SizedBox(
                        width: 20,
                      ),
                      const Divider(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() != true) {
                                  return;
                                }

                                final success = await notif.saveMeal();
                                if (!context.mounted) {
                                  return;
                                }

                                if (success) {
                                  Navigator.of(context).pop();
                                } else {
                                  final error =
                                      ref.read(manageMealProvider).errorMessage;
                                  UIUtil.bottomNotifier(
                                    context: context,
                                    message: error.isEmpty
                                        ? "Failed to save meal"
                                        : error,
                                  );
                                }
                              },
                              child: const Text("Save")),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _showEstimatedMacros(Macros macros) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Meal Contains:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ListTile(
          subtitle: Text(
              "Calories: ${macros.calories} | Protein: ${macros.protein} | Fats: ${macros.fats} | Carbs: ${macros.carbs}"),
          // isThreeLine: true,
        ),
      ],
    );
  }

  Widget _showErrorMessage(BuildContext context, String message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

class _MealItemsEditor extends ConsumerWidget {
  const _MealItemsEditor();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manageMealProvider);
    final foods = state.foods;
    final notif = ref.read(manageMealProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Food items:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < state.formInputs.items.length; index++) ...[
          _MealItemRow(index: index),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: foods.isEmpty ? null : notif.addItem,
            icon: const Icon(Icons.add),
            label: const Text("Add Food"),
          ),
        ),
      ],
    );
  }
}

class _MealItemRow extends ConsumerWidget {
  const _MealItemRow({required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manageMealProvider);
    if (index >= state.formInputs.items.length) {
      return const SizedBox.shrink();
    }

    final item = state.formInputs.items[index];
    final foods = state.foods;
    final notif = ref.read(manageMealProvider.notifier);

    Food? selectedFood;
    for (final food in foods) {
      if (food.id == item.food.id) {
        selectedFood = food;
        break;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<Food>(
            decoration: const InputDecoration(
              label: Text("Food"),
              border: OutlineInputBorder(),
            ),
            isExpanded: true,
            value: selectedFood,
            validator: (food) {
              if (food == null) {
                return "Select food";
              }
              return null;
            },
            items: foods
                .map((food) => DropdownMenuItem(
                      value: food,
                      child: Text(
                        food.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (food) {
              if (food != null) {
                notif.updateItem(index, food: food);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: TextFormField(
            key: ValueKey("meal-item-$index-${item.food.id}"),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: item.amount.toString(),
            validator: (amount) {
              final value = double.tryParse(amount ?? "");
              if (value == null || value <= 0 || !value.isFinite) {
                return "Invalid";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Amount",
              border: const OutlineInputBorder(),
              suffixText: item.food.unit.name,
            ),
            onChanged: (amount) {
              final value = double.tryParse(amount);
              if (value != null) {
                notif.updateItem(index, amount: value);
              }
            },
          ),
        ),
        IconButton(
          tooltip: "Remove food",
          onPressed: state.formInputs.items.length <= 1
              ? null
              : () => notif.removeItem(index),
          icon: const Icon(Icons.remove_circle_outline),
        ),
      ],
    );
  }
}
