import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:macro_diary/features/food/data/services/food_local_service.dart';
import 'package:macro_diary/features/user_data/data/models/user_profile_isar.dart';
import 'package:macro_diary/features/user_data/domain/entities/personal_details.dart';

final personalDetailsProvider = AsyncNotifierProvider.autoDispose<
    PersonalDetailsNotifier, PersonalDetailsState>(
  PersonalDetailsNotifier.new,
);

class PersonalDetailsNotifier
    extends AutoDisposeAsyncNotifier<PersonalDetailsState> {
  Isar get _isar => ref.read(isarProvider);

  @override
  FutureOr<PersonalDetailsState> build() async {
    final profile = await _isar.userProfileIsars.get(1);
    return PersonalDetailsState(
      formInputs: PersonalDetailsFormInputs.fromProfile(profile),
      inputRevision: 1,
    );
  }

  void updateInputs({
    String? name,
    Gender? gender,
    String? age,
    String? heightCm,
    String? weightKg,
    ActivityLevel? activityLevel,
  }) {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        formInputs: current.formInputs.copyWith(
          name: name,
          gender: gender,
          age: age,
          heightCm: heightCm,
          weightKg: weightKg,
          activityLevel: activityLevel,
        ),
        errorMessage: "",
      ),
    );
  }

  Future<bool> savePersonalDetails() async {
    final current = state.value;
    if (current == null) return false;

    final inputs = current.formInputs;
    final validationMessage = inputs.validationMessage;
    if (validationMessage != null) {
      state = AsyncData(current.copyWith(errorMessage: validationMessage));
      return false;
    }

    state = AsyncData(current.copyWith(isSaving: true, errorMessage: ""));

    try {
      final profile = await _isar.userProfileIsars.get(1) ?? UserProfileIsar();
      final updatedProfile = inputs.applyToProfile(profile)
        ..updatedAt = DateTime.now();

      await _isar.writeTxn(() async {
        await _isar.userProfileIsars.put(updatedProfile);
      });

      final updatedState = state.value ?? current;
      state = AsyncData(
        updatedState.copyWith(
          isSaving: false,
          formInputs: PersonalDetailsFormInputs.fromProfile(updatedProfile),
          inputRevision: updatedState.inputRevision + 1,
        ),
      );
      return true;
    } catch (_) {
      final updatedState = state.value ?? current;
      state = AsyncData(
        updatedState.copyWith(
          isSaving: false,
          errorMessage: "Failed to save personal details.",
        ),
      );
      return false;
    }
  }
}

class PersonalDetailsFormInputs {
  final String name;
  final Gender? gender;
  final String age;
  final String heightCm;
  final String weightKg;
  final ActivityLevel? activityLevel;

  const PersonalDetailsFormInputs({
    this.name = "",
    this.gender,
    this.age = "",
    this.heightCm = "",
    this.weightKg = "",
    this.activityLevel,
  });

  factory PersonalDetailsFormInputs.fromProfile(UserProfileIsar? profile) {
    if (profile == null) return const PersonalDetailsFormInputs();

    return PersonalDetailsFormInputs(
      name: profile.name,
      gender: genderFromName(profile.gender),
      age: profile.age?.toString() ?? "",
      heightCm: _formatNumber(profile.heightCm),
      weightKg: _formatNumber(profile.weightKg),
      activityLevel: activityLevelFromName(profile.activityLevel),
    );
  }

  String? get validationMessage {
    if (gender == null) return "Please select a gender.";
    if (_validInt(age, min: 13, max: 100) == null) {
      return "Age must be between 13 and 100.";
    }
    if (_validDouble(heightCm, min: 80, max: 250) == null) {
      return "Height must be between 80 and 250 cm.";
    }
    if (_validDouble(weightKg, min: 25, max: 250) == null) {
      return "Weight must be between 25 and 250 kg.";
    }
    if (activityLevel == null) return "Please select an activity level.";
    return null;
  }

  UserProfileIsar applyToProfile(UserProfileIsar profile) {
    return profile
      ..id = 1
      ..name = name.trim()
      ..gender = gender!.name
      ..age = _validInt(age, min: 13, max: 100)
      ..heightCm = _validDouble(heightCm, min: 80, max: 250)
      ..weightKg = _validDouble(weightKg, min: 25, max: 250)
      ..activityLevel = activityLevel!.name;
  }

  PersonalDetailsFormInputs copyWith({
    String? name,
    Gender? gender,
    String? age,
    String? heightCm,
    String? weightKg,
    ActivityLevel? activityLevel,
  }) {
    return PersonalDetailsFormInputs(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  static String _formatNumber(double? value) {
    if (value == null) return "";
    if (value % 1 == 0) return value.toInt().toString();
    return value.toString();
  }

  static int? _validInt(
    String value, {
    required int min,
    required int max,
  }) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < min || parsed > max) return null;
    return parsed;
  }

  static double? _validDouble(
    String value, {
    required double min,
    required double max,
  }) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < min || parsed > max || !parsed.isFinite) {
      return null;
    }
    return parsed;
  }
}

class PersonalDetailsState {
  final PersonalDetailsFormInputs formInputs;
  final bool isSaving;
  final String errorMessage;
  final int inputRevision;

  const PersonalDetailsState({
    this.formInputs = const PersonalDetailsFormInputs(),
    this.isSaving = false,
    this.errorMessage = "",
    this.inputRevision = 0,
  });

  PersonalDetailsState copyWith({
    PersonalDetailsFormInputs? formInputs,
    bool? isSaving,
    String? errorMessage,
    int? inputRevision,
  }) {
    return PersonalDetailsState(
      formInputs: formInputs ?? this.formInputs,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      inputRevision: inputRevision ?? this.inputRevision,
    );
  }
}
