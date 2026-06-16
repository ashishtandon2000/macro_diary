enum Gender {
  male,
  female,
}

extension GenderInfo on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return "Male";
      case Gender.female:
        return "Female";
    }
  }
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
}

extension ActivityLevelInfo on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.sedentary:
        return "Sedentary";
      case ActivityLevel.lightlyActive:
        return "Lightly active";
      case ActivityLevel.moderatelyActive:
        return "Moderately active";
      case ActivityLevel.veryActive:
        return "Very active";
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return "little or no exercise";
      case ActivityLevel.lightlyActive:
        return "exercise 1-3 days/week";
      case ActivityLevel.moderatelyActive:
        return "exercise 3-5 days/week";
      case ActivityLevel.veryActive:
        return "hard exercise/sports 5-6 days/week";
    }
  }

  String get fullLabel => "$label - $description";
}

Gender? genderFromName(String value) {
  for (final gender in Gender.values) {
    if (gender.name == value) return gender;
  }
  return null;
}

ActivityLevel? activityLevelFromName(String value) {
  for (final level in ActivityLevel.values) {
    if (level.name == value) return level;
  }
  return null;
}
