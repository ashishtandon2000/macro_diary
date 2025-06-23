import 'package:shared_preferences/shared_preferences.dart';

class DB {
  DB._();
  static final _pvt = DB._();
  factory DB() => _pvt;

  SharedPreferences? _dbInstance;

  Future<bool> init()async{
    _dbInstance = await SharedPreferences.getInstance();
    return true;
  }

  /// Safe to use, will always returns shared prefs instance and if not initialized, it will first make sure to initialize it.
  /// To be used in edge cases where init might not be called.
  Future<SharedPreferences> get safeInstance async{
    if(_dbInstance == null){
      await init();
    }

    return _dbInstance!;
  }

  /// Returns shared prefs instance if initialized, otherwise throws exception.
  SharedPreferences get instance {
    if (_dbInstance == null) {
      throw Exception("SharedPreferences not initialized. Use safeInstance or await init().");
    }
    return _dbInstance!;
  }

  /// Get all will return all the values of specific type using unique keys of each repo eg: food_items, food_servings, summary
  List<String?> getAll(String uniqueKey){
    final keys = instance.getKeys().where((key) => key.startsWith(uniqueKey)).toList();

    return keys.map(
            (key)=>instance.getString(key)
    ).toList();
  }
}