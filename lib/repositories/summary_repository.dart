
import 'package:macro_diary/models/summary.dart';

abstract class ISummaryRepository {

  Future<Macros> getCurrentSummary();

}

class SummaryRepositoryImpl implements ISummaryRepository {

  @override
  Future<Macros> getCurrentSummary() async {
    return Macros(
      protein: 0,
      carbs: 0,
      fats: 0,
      calories: 0,
    );
  }
}
