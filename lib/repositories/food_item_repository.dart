import 'package:macro_diary/common/common.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/repositories/db.dart';
import 'package:macro_diary/repositories/util.dart';

abstract class IFoodRepository { // I is standard used for interfaces

  Future<List<FoodItem>> getAll();
  Future<FoodItem?> get(String foodId);
  Future<void> create(FoodItem item);
  Future<bool> delete(String foodId);
}

class FoodRepositoryImpl implements IFoodRepository {

  final _uniqueKey = "food_items";
  key(String id) => "${_uniqueKey}_$id";

  @override
  Future<List<FoodItem>> getAll()async{
    final data = DB().getAll(_uniqueKey);

    final List<FoodItem> items = [];

    for(var itemStr in data){
      if(itemStr != null){
        final item = Codec.decode<FoodItem>(itemStr);
        if(item != null){
          items.add(item);
        }
      }
    }

    // #DEBUG #ONETIME
    print("");
    items.forEach((item)=>Util.print.debug("#ONETIME Food items from repo are: ${item.toString()}"));
    print("");


    return items;
  }

  @override
  Future<FoodItem?> get(String foodId)async{

    final data = DB().instance.getString(key(foodId));
    if(data != null){
       return Codec.decode<FoodItem>(data);
    }
    return null;
  }

  @override
  Future<bool> create(FoodItem item)async{
    final data = Codec.encode(item);
    return await DB().instance.setString(key(item.id), data);
  }

  @override
  Future<bool> delete(String foodId)async{
    return await DB().instance.remove(key(foodId));
  }
}

