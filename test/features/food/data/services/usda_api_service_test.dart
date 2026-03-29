

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:macro_diary/core/errors/exceptions.dart';
import 'package:macro_diary/features/food/data/models/food_model.dart';

class UsdaApiService {
  final http.Client client;
  final String apiKey;


  const UsdaApiService({
    required this.client,
    required this.apiKey
  });

  Future searchFood(String query)async{
    final uri = Uri.parse(
      "https://api.nal.usda.gov/fdc/v1/foods/search"
        '?query=$query&api_key=$apiKey&pageSize=5'
    );

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw ServerException();
    }

    try {
      final decoded = jsonDecode(response.body);
      final foods = decoded['foods'] as List;

      return foods
          .map((json) => FoodModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ParsingException("Failed to parse USDA response");
    }
  }



}