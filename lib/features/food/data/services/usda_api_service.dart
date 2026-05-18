import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:macro_diary/core/errors/exceptions.dart';
import 'package:macro_diary/core/util/http.dart';
import 'package:macro_diary/core/util/prints.dart';
import 'package:macro_diary/features/food/data/models/food_model.dart';

final usdaProvider = Provider<UsdaApiService>((ref) {
  final client = ref.read(httpClientProvider);
  const key = String.fromEnvironment("usda_api_key", defaultValue: "DEMO_KEY");
  return UsdaApiService(client: client, apiKey: key);
});

class UsdaApiService {
  final http.Client client;
  final String apiKey;

  const UsdaApiService({
    required this.client,
    required this.apiKey
  });

  Future<List<FoodModel>> searchFoods(String query) async {
    final uri = Uri.https(
      "api.nal.usda.gov",
      "/fdc/v1/foods/search",
      {
        "query": query,
        "api_key": apiKey,
        "pageSize": "5",
      },
    );

    final response = await client.get(
      uri,
      headers: {
        'Accept': 'application/json',
      }
    );

    if (response.statusCode != 200) {
      Print.debug("Failed USDA response${response.body}");
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