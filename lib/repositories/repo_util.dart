
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/food_serving.dart';

class Codec{

  static String encode(Object obj){
    return jsonEncode(obj);
  }

  static T? decode<T>(String data){

    final Map<String, dynamic> json = jsonDecode(data);

    try{
      switch(T){
        case const (FoodItem):
          FoodItem foodItem = FoodItem.fromJson(json);
          break;
          case const (FoodServing):

            break;
        case const (Summary):

          break;
        default:
          break;

      }



    }catch(e){
        return null;
    }


    return null;
  }

}

/// Approach 1: ask for type while decoding...
/// Approach 2: store type in json map like- {
//   "type": "User",
//   "data": { ... }
// }
