import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:macro_diary/features/food/data/services/food_local_service.dart';
import 'package:macro_diary/features/user_data/data/models/user_profile_isar.dart';
import 'package:macro_diary/features/user_data/domain/entities/macro_target.dart';
import 'package:macro_diary/features/user_data/domain/entities/personal_details.dart';

final targetsProvider =
    AsyncNotifierProvider.autoDispose<TargetsNotifier, TargetsState>(
  TargetsNotifier.new,
);

class TargetsNotifier extends AutoDisposeAsyncNotifier<TargetsState> {
  Isar get _isar => ref.read(isarProvider);

  @override
  FutureOr<TargetsState> build() async {
    final profile = await _isar.userProfileIsars.get(1);
    return _stateFromProfile(profile);
  }

  void updateGoal(FitnessGoal goal) {
    final current = state.value;
    if (current == null || !current.hasCompletePersonalDetails) return;

    state = AsyncData(
      current.copyWith(
        selectedGoal: goal,
        estimate: _estimateFor(current.profile!, goal),
        errorMessage: "",
      ),
    );
  }

  Future<bool> saveTarget() async {
    final current = state.value;
    final profile = current?.profile;
    final goal = current?.selectedGoal;
    if (current == null || profile == null || goal == null) {
      state = AsyncData(
        current?.copyWith(errorMessage: "Please select a goal.") ??
            const TargetsState(errorMessage: "Please select a goal."),
      );
      return false;
    }

    if (!current.hasCompletePersonalDetails) {
      state = AsyncData(
        current.copyWith(
          errorMessage:
              "Please complete your personal details first to calculate your target.",
        ),
      );
      return false;
    }

    final estimate = _estimateFor(profile, goal);
    state = AsyncData(current.copyWith(isSaving: true, errorMessage: ""));

    try {
      final now = DateTime.now();
      profile
        ..goalType = goal.name
        ..bmr = estimate.bmr
        ..tdee = estimate.tdee
        ..targetCalories = estimate.targetCalories
        ..targetProtein = estimate.targetProtein
        ..targetCarbs = estimate.targetCarbs
        ..targetFats = estimate.targetFats
        ..personalDetailsUpdatedAt ??= profile.updatedAt
        ..targetUpdatedAt = now
        ..updatedAt = now;

      await _isar.writeTxn(() async {
        await _isar.userProfileIsars.put(profile);
      });

      final updatedState = _stateFromProfile(profile).copyWith(
        isSaving: false,
        estimate: estimate,
      );
      state = AsyncData(updatedState);
      return true;
    } catch (_) {
      final updatedState = state.value ?? current;
      state = AsyncData(
        updatedState.copyWith(
          isSaving: false,
          errorMessage: "Failed to save target.",
        ),
      );
      return false;
    }
  }

  TargetsState _stateFromProfile(UserProfileIsar? profile) {
    final hasCompleteDetails = _hasCompletePersonalDetails(profile);
    if (!hasCompleteDetails || profile == null) {
      return TargetsState(
        profile: profile,
        hasCompletePersonalDetails: false,
      );
    }

    final selectedGoal = fitnessGoalFromName(profile.goalType);
    return TargetsState(
      profile: profile,
      hasCompletePersonalDetails: true,
      selectedGoal: selectedGoal,
      estimate:
          selectedGoal == null ? null : _estimateFor(profile, selectedGoal),
      personalDetailsChanged: _personalDetailsChangedSinceTargetSave(profile),
    );
  }

  MacroTargetEstimate _estimateFor(UserProfileIsar profile, FitnessGoal goal) {
    return calculateMacroTarget(
      gender: genderFromName(profile.gender)!,
      age: profile.age!,
      heightCm: profile.heightCm!,
      weightKg: profile.weightKg!,
      activityLevel: activityLevelFromName(profile.activityLevel)!,
      goal: goal,
    );
  }

  bool _hasCompletePersonalDetails(UserProfileIsar? profile) {
    if (profile == null) return false;
    final gender = genderFromName(profile.gender);
    final activityLevel = activityLevelFromName(profile.activityLevel);
    final age = profile.age;
    final height = profile.heightCm;
    final weight = profile.weightKg;

    return gender != null &&
        activityLevel != null &&
        age != null &&
        age >= 13 &&
        age <= 100 &&
        height != null &&
        height >= 80 &&
        height <= 250 &&
        weight != null &&
        weight >= 25 &&
        weight <= 250;
  }

  bool _personalDetailsChangedSinceTargetSave(UserProfileIsar profile) {
    final personalDetailsUpdatedAt = profile.personalDetailsUpdatedAt;
    final targetUpdatedAt = profile.targetUpdatedAt;
    if (personalDetailsUpdatedAt == null || targetUpdatedAt == null) {
      return false;
    }
    return personalDetailsUpdatedAt.isAfter(targetUpdatedAt);
  }
}

class TargetsState {
  final UserProfileIsar? profile;
  final bool hasCompletePersonalDetails;
  final FitnessGoal? selectedGoal;
  final MacroTargetEstimate? estimate;
  final bool personalDetailsChanged;
  final bool isSaving;
  final String errorMessage;

  const TargetsState({
    this.profile,
    this.hasCompletePersonalDetails = false,
    this.selectedGoal,
    this.estimate,
    this.personalDetailsChanged = false,
    this.isSaving = false,
    this.errorMessage = "",
  });

  TargetsState copyWith({
    UserProfileIsar? profile,
    bool? hasCompletePersonalDetails,
    FitnessGoal? selectedGoal,
    MacroTargetEstimate? estimate,
    bool? personalDetailsChanged,
    bool? isSaving,
    String? errorMessage,
  }) {
    return TargetsState(
      profile: profile ?? this.profile,
      hasCompletePersonalDetails:
          hasCompletePersonalDetails ?? this.hasCompletePersonalDetails,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      estimate: estimate ?? this.estimate,
      personalDetailsChanged:
          personalDetailsChanged ?? this.personalDetailsChanged,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
