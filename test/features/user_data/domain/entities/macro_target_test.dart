import 'package:flutter_test/flutter_test.dart';
import 'package:macro_diary/features/user_data/domain/entities/macro_target.dart';
import 'package:macro_diary/features/user_data/domain/entities/personal_details.dart';

void main() {
  test("calculates a fat loss target from profile details", () {
    final estimate = calculateMacroTarget(
      gender: Gender.male,
      age: 30,
      heightCm: 180,
      weightKg: 75,
      activityLevel: ActivityLevel.moderatelyActive,
      goal: FitnessGoal.fatLossModerate,
    );

    expect(estimate.bmr, closeTo(1730, 0.001));
    expect(estimate.tdee, closeTo(2681.5, 0.001));
    expect(estimate.targetCalories, closeTo(2279.275, 0.001));
    expect(estimate.targetProtein, closeTo(150, 0.001));
    expect(estimate.targetFats, closeTo(52.5, 0.001));
    expect(estimate.targetCarbs, closeTo(301.69375, 0.001));
    expect(estimate.targetTooLow, isFalse);
  });

  test("sets carbs to zero when protein and fat exceed calories", () {
    final estimate = calculateMacroTarget(
      gender: Gender.female,
      age: 100,
      heightCm: 80,
      weightKg: 250,
      activityLevel: ActivityLevel.sedentary,
      goal: FitnessGoal.fatLossAggressive,
    );

    expect(estimate.targetCarbs, 0);
    expect(estimate.targetTooLow, isTrue);
  });
}
