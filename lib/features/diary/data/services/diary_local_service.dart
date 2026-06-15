import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:macro_diary/features/diary/data/models/diary_entry_isar.dart';
import 'package:macro_diary/features/food/data/services/food_local_service.dart';

final diaryLocalServiceProvider = Provider<DiaryLocalService>((ref) {
  final isar = ref.read(isarProvider);
  return DiaryLocalService(isar: isar);
});

class DiaryLocalService {
  final Isar isar;

  const DiaryLocalService({required this.isar});

  Future<int> addEntry(DiaryEntryIsar entry) async {
    return await isar.writeTxn(() async {
      return await isar.diaryEntryIsars.put(entry);
    });
  }

  Future<void> deleteEntry(int id) async {
    await isar.writeTxn(() async {
      await isar.diaryEntryIsars.delete(id);
    });
  }

  Future<void> deleteEntries(List<int> ids) async {
    await isar.writeTxn(() async {
      await isar.diaryEntryIsars.deleteAll(ids);
    });
  }

  Future<List<DiaryEntryIsar>> getAllEntries() async {
    return await isar.diaryEntryIsars.where().findAll();
  }
}
