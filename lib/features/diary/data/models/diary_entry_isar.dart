import 'package:isar/isar.dart';
import 'package:macro_diary/core/domain/entities/macros.dart';
import 'package:macro_diary/features/diary/domain/entities/diary_entry.dart';

part 'diary_entry_isar.g.dart';

@collection
class DiaryEntryIsar {
  Id id = Isar.autoIncrement;

  String type = DiaryEntryType.custom.name;
  String title = "";
  DateTime consumedAt = DateTime.now();
  String? sourceId;
  List<String> details = [];

  double calories = 0;
  double protein = 0;
  double carbs = 0;
  double fats = 0;

  DiaryEntry toEntity() {
    return DiaryEntry(
      id: id.toString(),
      type: DiaryEntryType.values.firstWhere(
        (entryType) => entryType.name == type,
        orElse: () => DiaryEntryType.custom,
      ),
      title: title,
      macros: Macros(
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
      ),
      consumedAt: consumedAt,
      sourceId: sourceId,
      details: details,
    );
  }

  static DiaryEntryIsar fromEntity(DiaryEntry entry) {
    return DiaryEntryIsar()
      ..type = entry.type.name
      ..title = entry.title
      ..consumedAt = entry.consumedAt
      ..sourceId = entry.sourceId
      ..details = entry.details
      ..calories = entry.macros.calories
      ..protein = entry.macros.protein
      ..carbs = entry.macros.carbs
      ..fats = entry.macros.fats;
  }

  static DiaryEntryIsar fromEntityWithId(DiaryEntry entry) {
    return fromEntity(entry)..id = int.parse(entry.id);
  }
}
