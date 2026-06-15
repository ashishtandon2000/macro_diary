import 'package:macro_diary/core/domain/entities/macros.dart';

enum DiaryEntryType { custom, food, meal }

class DiaryEntry {
  final String id;
  final DiaryEntryType type;
  final String title;
  final Macros macros;
  final DateTime consumedAt;
  final String? sourceId;
  final List<String> details;

  const DiaryEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.macros,
    required this.consumedAt,
    this.sourceId,
    this.details = const [],
  });

  String get typeLabel {
    switch (type) {
      case DiaryEntryType.custom:
        return "Custom";
      case DiaryEntryType.food:
        return "Food";
      case DiaryEntryType.meal:
        return "Meal";
    }
  }
}
