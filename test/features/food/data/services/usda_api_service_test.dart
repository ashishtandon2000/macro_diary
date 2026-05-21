import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:macro_diary/core/errors/exceptions.dart';
import 'package:macro_diary/features/food/data/services/usda_api_service.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient client;
  late UsdaApiService service;

  const apiKey = "test-key";
  final searchUri = Uri.https(
    "api.nal.usda.gov",
    "/fdc/v1/foods/search",
    {
      "query": "apple",
      "api_key": apiKey,
      "pageSize": "5",
    },
  );

  setUp(() {
    client = MockHttpClient();
    service = UsdaApiService(client: client, apiKey: apiKey);
  });

  test("returns parsed foods from USDA search response", () async {
    when(() => client.get(searchUri)).thenAnswer(
      (_) async => http.Response(
        '''
        {
          "foods": [
            {
              "fdcId": 123,
              "description": "Apple, raw",
              "servingSizeUnit": "g",
              "foodNutrients": [
                {"nutrientId": 1008, "value": 52},
                {"nutrientId": 1003, "value": 0.3},
                {"nutrientId": 1005, "value": 13.8},
                {"nutrientId": 1004, "value": 0.2}
              ]
            }
          ]
        }
        ''',
        200,
      ),
    );

    final foods = await service.searchFoods("apple");

    expect(foods, hasLength(1));
    expect(foods.first.name, "Apple, raw");
    expect(foods.first.externalId, "123");
    expect(foods.first.macros.calories, 52);
    expect(foods.first.macros.protein, 0.3);
    expect(foods.first.macros.carbs, 13.8);
    expect(foods.first.macros.fats, 0.2);
    verify(() => client.get(searchUri)).called(1);
  });

  test("throws server exception when USDA responds with an error", () async {
    when(() => client.get(searchUri)).thenAnswer(
      (_) async => http.Response("{}", 500),
    );

    expect(
      () => service.searchFoods("apple"),
      throwsA(isA<ServerException>()),
    );
  });
}
