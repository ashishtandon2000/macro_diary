import 'package:macro_diary/features/diary/domain/entities/diary_entry.dart';

abstract class DiaryRepository {
  Future<DiaryEntry> addEntry(DiaryEntry entry);
  Future<void> deleteEntry(String entryId);
  Future<void> deleteEntriesForDay(DateTime day);
  Future<List<DiaryEntry>> getEntriesForDay(DateTime day);
}
