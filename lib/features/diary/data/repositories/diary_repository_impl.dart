import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/core/errors/failures.dart';
import 'package:macro_diary/features/diary/data/models/diary_entry_isar.dart';
import 'package:macro_diary/features/diary/data/services/diary_local_service.dart';
import 'package:macro_diary/features/diary/domain/entities/diary_entry.dart';
import 'package:macro_diary/features/diary/domain/repositories/diary_repository.dart';

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  final service = ref.read(diaryLocalServiceProvider);
  return DiaryRepositoryImpl(localService: service);
});

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryLocalService localService;

  const DiaryRepositoryImpl({required this.localService});

  @override
  Future<DiaryEntry> addEntry(DiaryEntry entry) async {
    try {
      final model = DiaryEntryIsar.fromEntity(entry);
      final id = await localService.addEntry(model);
      model.id = id;
      return model.toEntity();
    } catch (_) {
      throw const CacheFailure("Failed to save diary entry");
    }
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    try {
      await localService.deleteEntry(int.parse(entryId));
    } catch (_) {
      throw const CacheFailure("Failed to delete diary entry");
    }
  }

  @override
  Future<void> deleteEntriesForDay(DateTime day) async {
    try {
      final entries = await _getEntriesForDayModels(day);
      await localService.deleteEntries(
        entries.map((entry) => entry.id).toList(),
      );
    } catch (_) {
      throw const CacheFailure("Failed to delete diary entries");
    }
  }

  @override
  Future<List<DiaryEntry>> getEntriesForDay(DateTime day) async {
    try {
      final entries = await _getEntriesForDayModels(day);
      entries.sort((a, b) => a.consumedAt.compareTo(b.consumedAt));
      return entries.map((entry) => entry.toEntity()).toList();
    } catch (_) {
      throw const CacheFailure("Failed to fetch diary entries");
    }
  }

  Future<List<DiaryEntryIsar>> _getEntriesForDayModels(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final entries = await localService.getAllEntries();

    return entries.where((entry) {
      return !entry.consumedAt.isBefore(start) &&
          entry.consumedAt.isBefore(end);
    }).toList();
  }
}
