
import 'package:macro_diary/models/macros.dart';
import 'package:macro_diary/repositories/db.dart';
import 'package:macro_diary/repositories/util.dart';

abstract class ISummaryRepository {

  Macros getCurrentSummary();
  // Future<bool> addToSummary(Macros macros); // adds to existing summary
  Future<bool> overrideSummary(Macros macros); // overrides summary with new macros
}

class SummaryRepositoryImpl implements ISummaryRepository {

  final _uniqueKey = "food_summary";
  key(String id) => "${_uniqueKey}_$id";

  String _getDailyKey() {
    final now = DateTime.now();
    final dayKey = "${now.year}-${now.month}-${now.day}";
    return dayKey; // Example: "2025-6-26"
  }

  @override
  Macros getCurrentSummary() {

    final todayKey = key(_getDailyKey());

    final data =  DB().instance.getString(todayKey);

    if(data!=null){
     return Codec.decode<Macros>(data);
    }
    return Macros(
        calories: 0,
        protein: 0,
        carbs: 0,
        fats: 0
    );
  }

  // @override
  // Future<bool> addToSummary(Macros macros) async {
  //   final todayKey = key(_getDailyKey());
  //
  //   final currentSummary = getCurrentSummary();
  //   currentSummary.add(macros);
  //
  //   final json = Codec.encode(currentSummary);
  //
  //   return await DB().instance.setString(todayKey, json);
  // }

  @override
  Future<bool> overrideSummary(Macros macros) async {
    final todayKey = key(_getDailyKey());

    final json = Codec.encode(macros);

    return await DB().instance.setString(todayKey, json);
  }
}
