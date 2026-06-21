import 'dart:math';

import 'package:macro_diary/features/user_data/domain/entities/personal_details.dart';

enum FitnessGoal {
  fatLossAggressive,
  fatLossModerate,
  maintainWeight,
  leanBulk,
  bulkAggressive,
}

extension FitnessGoalInfo on FitnessGoal {
  String get label {
    switch (this) {
      case FitnessGoal.fatLossAggressive:
        return "Fat Loss - Aggressive";
      case FitnessGoal.fatLossModerate:
        return "Fat Loss - Moderate";
      case FitnessGoal.maintainWeight:
        return "Maintain Weight";
      case FitnessGoal.leanBulk:
        return "Lean Bulk";
      case FitnessGoal.bulkAggressive:
        return "Bulk - Aggressive";
    }
  }

  double get proteinPerKg {
    switch (this) {
      case FitnessGoal.fatLossAggressive:
        return 2.2;
      case FitnessGoal.fatLossModerate:
        return 2.0;
      case FitnessGoal.maintainWeight:
      case FitnessGoal.leanBulk:
        return 1.8;
      case FitnessGoal.bulkAggressive:
        return 1.6;
    }
  }

  double get fatsPerKg {
    switch (this) {
      case FitnessGoal.fatLossAggressive:
        return 0.6;
      case FitnessGoal.fatLossModerate:
        return 0.7;
      case FitnessGoal.maintainWeight:
        return 0.8;
      case FitnessGoal.leanBulk:
        return 0.9;
      case FitnessGoal.bulkAggressive:
        return 1.0;
    }
  }

  String? get caution {
    switch (this) {
      case FitnessGoal.fatLossAggressive:
        return "Aggressive fat loss may reduce workout performance and energy. Use this only for short periods.";
      case FitnessGoal.bulkAggressive:
        return "Aggressive bulk may increase fat gain along with muscle gain.";
      case FitnessGoal.fatLossModerate:
      case FitnessGoal.maintainWeight:
      case FitnessGoal.leanBulk:
        return null;
    }
  }
}

FitnessGoal? fitnessGoalFromName(String value) {
  for (final goal in FitnessGoal.values) {
    if (goal.name == value || goal.label == value) return goal;
  }
  return null;
}

class MacroTargetEstimate {
  final FitnessGoal goal;
  final double bmr;
  final double tdee;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFats;
  final bool targetTooLow;

  const MacroTargetEstimate({
    required this.goal,
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFats,
    required this.targetTooLow,
  });

  int get roundedBmr => bmr.round();
  int get roundedTdee => tdee.round();
  int get roundedCalories => targetCalories.round();
  int get roundedProtein => targetProtein.round();
  int get roundedCarbs => targetCarbs.round();
  int get roundedFats => targetFats.round();
}

MacroTargetEstimate calculateMacroTarget({
  required Gender gender,
  required int age,
  required double heightCm,
  required double weightKg,
  required ActivityLevel activityLevel,
  required FitnessGoal goal,
}) {
  final bmr = switch (gender) {
    Gender.male => 10 * weightKg + 6.25 * heightCm - 5 * age + 5,
    Gender.female => 10 * weightKg + 6.25 * heightCm - 5 * age - 161,
  };
  final tdee = bmr * activityLevel.multiplier;
  final targetCalories = switch (goal) {
    FitnessGoal.fatLossAggressive => tdee * 0.80,
    FitnessGoal.fatLossModerate => tdee * 0.85,
    FitnessGoal.maintainWeight => tdee,
    FitnessGoal.leanBulk => tdee + 250,
    FitnessGoal.bulkAggressive => tdee + 500,
  };

  final protein = weightKg * goal.proteinPerKg;
  final fats = weightKg * goal.fatsPerKg;
  final remainingCalories = targetCalories - protein * 4 - fats * 9;
  final carbs = max(0, remainingCalories / 4);

  return MacroTargetEstimate(
    goal: goal,
    bmr: bmr,
    tdee: tdee,
    targetCalories: targetCalories,
    targetProtein: protein,
    targetCarbs: carbs.toDouble(),
    targetFats: fats,
    targetTooLow: remainingCalories < 0,
  );
}
