import 'package:flutter/material.dart';
import 'package:macro_diary/features/home_screen/view/home_screen.dart';
import 'package:macro_diary/features/home_screen/view_model/home_screen_viewmodel.dart';
import 'package:macro_diary/repositories/db.dart';
import 'package:macro_diary/repositories/food_item_repository.dart';
import 'package:macro_diary/repositories/food_serving_repository.dart';
import 'package:macro_diary/repositories/summary_repository.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await DB().init();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<HomeScreenViewmodel>(
        create: (_) => HomeScreenViewmodel(
          servingRepo: ServingRepositoryImpl(),
          foodRepo:    FoodRepositoryImpl(),
          summaryRepo: SummaryRepositoryImpl(),
        ),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            secondary: const Color(0xFF009688),
            tertiary: const Color(0xFFFFC107),
        ),
        useMaterial3: true,
      ),
      // darkTheme: ThemeData(
      //   brightness: Brightness.dark,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color(0xFF4CAF50),
      //     secondary: const Color(0xFF009688),
      //     tertiary: const Color(0xFFFFC107),
      //     brightness: Brightness.dark,
      //   ),
      //   useMaterial3: true,
      // ),
      home: const HomeScreen(),
    );
  }
}