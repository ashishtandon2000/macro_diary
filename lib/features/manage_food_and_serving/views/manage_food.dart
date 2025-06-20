import 'package:flutter/material.dart';
import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/features/manage_food_and_serving/view_models/manage_food_viewmodel.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:provider/provider.dart';

class ManageFood extends StatefulWidget {
  /// Create or edit food entry
  const ManageFood({super.key, this.foodId});

  /// In case of editing existing entry foodId will be passed, and in case of new entry foodId will be null
  final String? foodId;

  @override
  State<ManageFood> createState() => _ManageFoodState();
}

Map<MeasureUnit, String> _unitMap = {
  MeasureUnit.gram: 'Per 100 gram',
  MeasureUnit.milliliter: 'Per 100 milliliter',
  MeasureUnit.piece: 'Per piece'
};

class _ManageFoodState extends State<ManageFood> {
  
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();

    final id = widget.foodId ?? "";
    if (id.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((d) {
        final model = context.read<ManageFoodViewmodel>();
        model.initialLoading(id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mv = context.watch<ManageFoodViewmodel>();

    var appBarTitle = "";
    var initialData = mv.food; // if createMode entries will have zero values by default

    Util.print.debug("Initial Data in viewModel is ${initialData.toString()}");

    if (mv.createMode) {
      appBarTitle = "Create Food";
    } else {
      appBarTitle = "Edit Food";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
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
                      TextFormField(
                        initialValue: initialData.name,
                        autocorrect: true,
                        enableSuggestions: true,
                        decoration: const InputDecoration(
                            labelText: "Food Name",
                            border: OutlineInputBorder(),
                            hintText: "Food..."),
                      ),
                      DropdownButtonFormField(
                        value: initialData.unit,
                        onChanged: (selectedUint) {},
                        items: MeasureUnit.values
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(_unitMap[unit] ?? "Standard Unit"),
                              ),
                            )
                            .toList(),
                      )
                    ],
                  ),
                ),
              ),
          ),
    );
  }
}

// Unit selection view
// Expanded(
//   child: DropdownButtonFormField(
//     decoration: const InputDecoration(
//       labelText: "Unit",
//       border: OutlineInputBorder(),
//     ),
//     value: unit,
//     items: MeasureUnit.values
//         .map(
//           (e) => DropdownMenuItem(
//             value: e,
//             child: Text(e.name),
//           ),
//         )
//         .toList(),
//     onChanged: (val) {},
//   ),
// )
