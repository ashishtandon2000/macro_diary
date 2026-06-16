import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/user_data/domain/entities/personal_details.dart';
import 'package:macro_diary/features/user_data/presentation/view_model/personal_details_viewmodel.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  ConsumerState<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(personalDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Details"),
      ),
      body: asyncState.when(
        data: _buildForm,
        loading: () => UIUtil.circularLoader,
        error: (error, stackTrace) => UIUtil.nullScreenMsg("Error: $error"),
      ),
    );
  }

  Widget _buildForm(PersonalDetailsState state) {
    final inputs = state.formInputs;
    final notifier = ref.read(personalDetailsProvider.notifier);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          if (state.errorMessage.isNotEmpty) ...[
            Text(
              state.errorMessage,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            key: ValueKey("name-${state.inputRevision}"),
            initialValue: inputs.name,
            textCapitalization: TextCapitalization.words,
            autocorrect: true,
            enableSuggestions: true,
            onChanged: (name) => notifier.updateInputs(name: name),
            decoration: const InputDecoration(
              labelText: "Name",
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Gender>(
            value: inputs.gender,
            decoration: const InputDecoration(
              labelText: "Gender",
              prefixIcon: Icon(Icons.wc_outlined),
            ),
            items: Gender.values
                .map(
                  (gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender.label),
                  ),
                )
                .toList(),
            validator: (gender) {
              if (gender == null) return "Please select a gender";
              return null;
            },
            onChanged: state.isSaving
                ? null
                : (gender) {
                    if (gender != null) {
                      notifier.updateInputs(gender: gender);
                    }
                  },
          ),
          const SizedBox(height: 16),
          TextFormField(
            key: ValueKey("age-${state.inputRevision}"),
            initialValue: inputs.age,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (age) => notifier.updateInputs(age: age),
            validator: _ageValidator,
            decoration: const InputDecoration(
              labelText: "Age",
              suffixText: "years",
              prefixIcon: Icon(Icons.cake_outlined),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final heightField = _decimalField(
                keyPrefix: "height",
                inputRevision: state.inputRevision,
                initialValue: inputs.heightCm,
                label: "Height",
                suffix: "cm",
                icon: Icons.height_outlined,
                validator: _heightValidator,
                onChanged: (height) => notifier.updateInputs(
                  heightCm: height,
                ),
              );
              final weightField = _decimalField(
                keyPrefix: "weight",
                inputRevision: state.inputRevision,
                initialValue: inputs.weightKg,
                label: "Weight",
                suffix: "kg",
                icon: Icons.monitor_weight_outlined,
                validator: _weightValidator,
                onChanged: (weight) => notifier.updateInputs(
                  weightKg: weight,
                ),
              );

              if (constraints.maxWidth < 520) {
                return Column(
                  children: [
                    heightField,
                    const SizedBox(height: 16),
                    weightField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: heightField),
                  const SizedBox(width: 16),
                  Expanded(child: weightField),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ActivityLevel>(
            value: inputs.activityLevel,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: "Activity Level",
              prefixIcon: Icon(Icons.directions_run_outlined),
            ),
            items: ActivityLevel.values
                .map(
                  (level) => DropdownMenuItem(
                    value: level,
                    child: Text(
                      level.fullLabel,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            validator: (level) {
              if (level == null) return "Please select an activity level";
              return null;
            },
            onChanged: state.isSaving
                ? null
                : (level) {
                    if (level != null) {
                      notifier.updateInputs(activityLevel: level);
                    }
                  },
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: state.isSaving ? null : _save,
              icon: state.isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decimalField({
    required String keyPrefix,
    required int inputRevision,
    required String initialValue,
    required String label,
    required String suffix,
    required IconData icon,
    required String? Function(String? value) validator,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      key: ValueKey("$keyPrefix-$inputRevision"),
      initialValue: initialValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
      ],
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon),
      ),
    );
  }

  String? _ageValidator(String? value) {
    final age = int.tryParse(value?.trim() ?? "");
    if (age == null) return "Age is required";
    if (age < 13 || age > 100) return "Use 13-100";
    return null;
  }

  String? _heightValidator(String? value) {
    final height = double.tryParse(value?.trim() ?? "");
    if (height == null) return "Height is required";
    if (height < 80 || height > 250 || !height.isFinite) return "Use 80-250";
    return null;
  }

  String? _weightValidator(String? value) {
    final weight = double.tryParse(value?.trim() ?? "");
    if (weight == null) return "Weight is required";
    if (weight < 25 || weight > 250 || !weight.isFinite) return "Use 25-250";
    return null;
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;

    final saved =
        await ref.read(personalDetailsProvider.notifier).savePersonalDetails();
    if (!mounted) return;

    UIUtil.bottomNotifier(
      context: context,
      message: saved ? "Personal details saved." : "Failed to save details.",
    );
  }
}
