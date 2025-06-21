
import 'dart:convert';

import 'package:macro_diary/models/food_item.dart';
import 'package:macro_diary/models/food_serving.dart';

class Codec{

  String encode(Object obj){
    return jsonEncode(obj);
  }

  T? decode<T>(){
    try{
      switch(T){
        case FoodItem:

          break;
          case FoodServing:

            break;

      }



    }catch(e){

    }


    return null;
  }

}

/// Approach 1: ask for type while decoding...
/// Approach 2: store type in json map like- {
//   "type": "User",
//   "data": { ... }
// }
