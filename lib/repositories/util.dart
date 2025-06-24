
import 'dart:convert';

import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/food_serving.dart';
import 'package:macro_diary/models/macros.dart';

class Codec{

  static String encode(Object obj){
    return jsonEncode(obj);
  }

  static dynamic decode<T>(String data){

    final Map<String, dynamic> json = jsonDecode(data);

    try{
      switch(T){
        case const (FoodItem):
          FoodItem foodItem = FoodItem.fromJson(json);
          return foodItem;

        case const (FoodServing):
          FoodServing foodServing = FoodServing.fromJson(json);
          return foodServing;

        case const (Macros):
          Macros macros = Macros.fromJson(json);
          return macros;

        default:
          throw("type $T is not supported by Codec.decoder ");
      }
    }catch(e){
        throw("Codec.decoder error: $e");
    }
  }

}

/// Approach 1: ask for type while decoding...
/// Approach 2: store type in json map like- {
//   "type": "User",
//   "data": { ... }
// }
