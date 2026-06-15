import 'package:isar/isar.dart';

part 'user_profile_isar.g.dart';

@collection
class UserProfileIsar {
  Id id = 1;

  String name = "";
  int? age;
  double? heightCm;
  double? weightKg;

  String goalType = "";
  double targetCalories = 0;
  double targetProtein = 0;
  double targetCarbs = 0;
  double targetFats = 0;

  double? bmr;
  double? tdee;
  bool hasCompletedGuide = false;
  DateTime updatedAt = DateTime.now();
}
