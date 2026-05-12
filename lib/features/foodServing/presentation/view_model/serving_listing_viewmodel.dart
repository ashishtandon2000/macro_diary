import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macro_diary/features/foodServing/domain/repositories/food_serving_repository.dart';

import '../../domain/entities/food_serving.dart';

class ServingListingNotifier extends AsyncNotifier<List<FoodServing>>{

  final FoodServingRepository _repository;
  
  ServingListingNotifier({required FoodServingRepository repository}):_repository = repository;

  @override
  Future<List<FoodServing>> build()async{
    return await _repository.getAllServings();
  }
  
  Future<void> updateList()async{
    state = AsyncData(await _repository.getAllServings());
  }

  Future<void> deleteServing(String servingId)async{
    await _repository.deleteServing(servingId);
    final current = state.value;
    if(current!=null){
      state = AsyncData(current.where((s)=>s.id!=servingId).toList());
    }
  }
}