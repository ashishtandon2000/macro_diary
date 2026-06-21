import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/widgets/ui_util.dart';
import 'package:macro_diary/features/user_data/domain/entities/macro_target.dart';
import 'package:macro_diary/features/user_data/presentation/view_model/targets_viewmodel.dart';

class TargetsScreen extends ConsumerWidget {
  const TargetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(targetsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Targets"),
      ),
      body: asyncState.when(
        data: (state) => _TargetsBody(state: state),
        loading: () => UIUtil.circularLoader,
        error: (error, stackTrace) => UIUtil.nullScreenMsg("Error: $error"),
      ),
    );
  }
}

class _TargetsBody extends ConsumerWidget {
  final TargetsState state;

  const _TargetsBody({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!state.hasCompletePersonalDetails) {
      return UIUtil.nullScreenMsg(
        "Please complete your personal details first to calculate your target.",
      );
    }

    final estimate = state.estimate;
    final goal = state.selectedGoal;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        if (state.errorMessage.isNotEmpty) ...[
          Text(
            state.errorMessage,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 12),
        ],
        if (state.personalDetailsChanged) ...[
          const _InfoMessage(
            icon: Icons.update_outlined,
            text:
                "Your personal details changed. Please review and save your updated target.",
          ),
          const SizedBox(height: 12),
        ],
        DropdownButtonFormField<FitnessGoal>(
          value: goal,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: "Goal",
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items: FitnessGoal.values
              .map(
                (goal) => DropdownMenuItem(
                  value: goal,
                  child: Text(goal.label),
                ),
              )
              .toList(),
          onChanged: state.isSaving
              ? null
              : (goal) {
                  if (goal != null) {
                    ref.read(targetsProvider.notifier).updateGoal(goal);
                  }
                },
        ),
        if (goal?.caution != null) ...[
          const SizedBox(height: 12),
          _InfoMessage(
            icon: Icons.warning_amber_outlined,
            text: goal!.caution!,
          ),
        ],
        if (estimate?.targetTooLow == true) ...[
          const SizedBox(height: 12),
          const _InfoMessage(
            icon: Icons.priority_high_outlined,
            text:
                "This target is too low for the selected protein and fat amounts, so suggested carbs are set to 0.",
          ),
        ],
        if (estimate != null) ...[
          const SizedBox(height: 20),
          _TargetPreview(estimate: estimate),
          const SizedBox(height: 12),
          Text(
            "This is a starting estimate. Follow it for 2 weeks and adjust based on weight trend and performance.",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: state.isSaving
                ? null
                : () async {
                    final saved =
                        await ref.read(targetsProvider.notifier).saveTarget();
                    if (!context.mounted) return;
                    UIUtil.bottomNotifier(
                      context: context,
                      message:
                          saved ? "Target saved." : "Failed to save target.",
                    );
                  },
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
    );
  }
}

class _TargetPreview extends StatelessWidget {
  final MacroTargetEstimate estimate;

  const _TargetPreview({required this.estimate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Suggested Daily Target",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _TargetRow(
              label: "Calories",
              value: "${estimate.roundedCalories} kcal",
            ),
            _TargetRow(
              label: "Protein",
              value: "${estimate.roundedProtein}g",
            ),
            _TargetRow(
              label: "Carbs",
              value: "${estimate.roundedCarbs}g",
            ),
            _TargetRow(
              label: "Fats",
              value: "${estimate.roundedFats}g",
            ),
            const Divider(height: 28),
            _TargetRow(
              label: "BMR",
              value: "${estimate.roundedBmr} kcal",
            ),
            _TargetRow(
              label: "Estimated maintenance",
              value: "${estimate.roundedTdee} kcal",
            ),
            _TargetRow(
              label: "Goal",
              value: estimate.goal.label,
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final String label;
  final String value;

  const _TargetRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoMessage extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoMessage({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
