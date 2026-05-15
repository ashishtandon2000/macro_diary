import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/food/domain/entities/food.dart';
import 'package:macro_diary/features/foodServing/presentation/view_model/manage_serving_viewmodel.dart';

class ManageServing extends ConsumerStatefulWidget {
  const ManageServing({super.key, this.servingId});

  final String? servingId;

  @override
  ConsumerState<ManageServing> createState() => _ManageServing();
}

class _ManageServing extends ConsumerState<ManageServing> {
  final _formKey = GlobalKey<FormState>();
  late final ManageServingNotifier notif;

  @override
  void initState() {
    super.initState();
    notif = ref.read(manageServingProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        notif.initialLoading(widget.servingId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manageServingProvider);

    return Scaffold(
      appBar: AppBar(
          title:
              Text((state.createMode) ? "Create Serving" : "Update Serving")),
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
                              return "Please enter a serving title";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Serving Title",
                              hintText: "Serving....",
                              prefixIcon: Icon(Icons.dinner_dining)),
                          onChanged: (t) {
                            notif.updateInputs(title: t);
                          }),
                      const SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        autocorrect: true,
                        enableSuggestions: true,
                        initialValue: state.formInputs.servingSize.toString(),
                        validator: (amount) {
                          final value = double.tryParse(amount ?? "");
                          if (value == null || value <= 0 || !value.isFinite) {
                            return "Enter a serving size greater than zero";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: "Serving Size",
                          hintText: "Amount....",
                          prefixIcon: const Icon(Icons.dinner_dining),
                          suffixText: state.formInputs.relativeFood.unit.name,
                        ),
                        onChanged: (amount) {
                          final safeValue = double.tryParse(amount);
                          if (safeValue != null) {
                            notif.updateInputs(servingSize: safeValue);
                          }
                        },
                      ),
                      _showEstimatedMacros(notif.getEstimatedMacros(
                          state.formInputs.servingSize,
                          state.formInputs.relativeFood)),
                      const SizedBox(
                        width: 20,
                      ),
                      const Divider(
                        height: 30,
                      ),
                      (state.createMode ||
                              state.formInputs.relativeFood.id.isEmpty)
                          ? const _FoodSelectionMenu()
                          : _showRelativeFood(state.formInputs.relativeFood),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() != true) {
                                  return;
                                }

                                final success = await notif.saveFoodServing();
                                if (!context.mounted) {
                                  return;
                                }

                                if (success) {
                                  Navigator.of(context).pop();
                                } else {
                                  final error = ref
                                      .read(manageServingProvider)
                                      .errorMessage;
                                  UIUtil.bottomNotifier(
                                    context: context,
                                    message: error.isEmpty
                                        ? "Failed to save serving"
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
          "Custom Serving Contain:",
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

  Widget _showRelativeFood(Food food) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Serving of:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListTile(
          title: Text(food.name),
          subtitle: Text(
              "Calories: ${food.macros.calories} | Protein: ${food.macros.protein} | Fats: ${food.macros.fats} | Carbs: ${food.macros.carbs}"),
          // isThreeLine: true,
        ),
      ],
    );
  }
}

class _FoodSelectionMenu extends ConsumerWidget {
  const _FoodSelectionMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(manageServingProvider);
    final foods = state.foods;
    final notif = ref.read(manageServingProvider.notifier);

    Food? selectedFood;
    for (final food in foods) {
      if (food.id == state.formInputs.relativeFood.id) {
        selectedFood = food;
        break;
      }
    }

    return DropdownButtonFormField<Food>(
      decoration: const InputDecoration(
        label: Text("Serving of: "),
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      value: selectedFood,
      validator: (food) {
        if (food == null) {
          return "Please select a food item";
        }
        return null;
      },
      items: foods
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.name),
              ))
          .toList(),
      onChanged: (food) {
        if (food != null) {
          notif.updateInputs(relativeFood: food);
        }
      },
    );
  }
}
