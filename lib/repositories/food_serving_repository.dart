import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/models/food_serving.dart';
import 'package:macro_diary/repositories/db.dart';
import 'package:macro_diary/repositories/util.dart';

abstract class IServingRepository {
  Future<FoodServing?> get(String servingId);
  Future<List<FoodServing>> getAll();
  Future<void> create(FoodServing serving);
  Future<bool> delete(String servingId);
}


class ServingRepositoryImpl implements IServingRepository{

  final _uniqueKey = "food_serving";
  key(String id) => "${_uniqueKey}_$id";

  @override
  Future<List<FoodServing>> getAll()async{
    final data = DB().getAll(_uniqueKey);

    final List<FoodServing> items = [];

    for(var itemStr in data){
      if(itemStr != null){
        final item = Codec.decode<FoodServing>(itemStr);
        if(item != null){
          items.add(item);
        }
      }
    }
    // #DEBUG #ONETIME
    print("");
    items.forEach((item)=>Util.print.debug("#ONETIME Food servings from repo are: ${item.toString()}"));
    print("");

    return items;
  }

  @override
  Future<FoodServing?> get(String servingId) async {
    final data = DB().instance.getString(key(servingId));
    if(data != null){
      return Codec.decode<FoodServing>(data);
    }
    return null;
  }

  @override
  Future<bool> create(FoodServing serving)async{
    final data = Codec.encode(serving);
    return await DB().instance.setString(key(serving.id), data);
  }

  @override
  Future<bool> delete(String servingId)async{
    return await DB().instance.remove(key(servingId));
  }
}