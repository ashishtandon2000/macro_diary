import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:macro_diary/features/dashboard/presentation/view/dashboard_screen.dart';
import 'package:macro_diary/features/diary/data/models/diary_entry_isar.dart';
import 'package:macro_diary/features/food/data/models/food_isar.dart';
import 'package:macro_diary/features/food/data/services/food_local_service.dart';
import 'package:macro_diary/features/meal/data/models/meal_isar.dart';
import 'package:macro_diary/features/user_data/data/models/user_profile_isar.dart';
import 'package:path_provider/path_provider.dart';

const _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF2F6F5E),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD4E8DF),
  onPrimaryContainer: Color(0xFF0E2A22),
  secondary: Color(0xFF496A73),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD7E5E8),
  onSecondaryContainer: Color(0xFF10272D),
  tertiary: Color(0xFFB7791F),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFE1AD),
  onTertiaryContainer: Color(0xFF3D2500),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFAFCF8),
  onSurface: Color(0xFF171D1B),
  surfaceDim: Color(0xFFD9DDD8),
  surfaceBright: Color(0xFFFAFCF8),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF2F6F1),
  surfaceContainer: Color(0xFFECEFEC),
  surfaceContainerHigh: Color(0xFFE6EAE5),
  surfaceContainerHighest: Color(0xFFE0E4DF),
  onSurfaceVariant: Color(0xFF414942),
  outline: Color(0xFF717970),
  outlineVariant: Color(0xFFC1C9BF),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF2C322F),
  onInverseSurface: Color(0xFFF0F3EE),
  inversePrimary: Color(0xFFA3D2C0),
  surfaceTint: Color(0xFF2F6F5E),
);

const _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFA3D2C0),
  onPrimary: Color(0xFF07382C),
  primaryContainer: Color(0xFF1A5547),
  onPrimaryContainer: Color(0xFFD4E8DF),
  secondary: Color(0xFFAFCBD2),
  onSecondary: Color(0xFF19333A),
  secondaryContainer: Color(0xFF314B53),
  onSecondaryContainer: Color(0xFFD7E5E8),
  tertiary: Color(0xFFE6BE79),
  onTertiary: Color(0xFF432B00),
  tertiaryContainer: Color(0xFF624000),
  onTertiaryContainer: Color(0xFFFFE1AD),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF0F1513),
  onSurface: Color(0xFFE2E7E1),
  surfaceDim: Color(0xFF0F1513),
  surfaceBright: Color(0xFF353B38),
  surfaceContainerLowest: Color(0xFF0A0F0D),
  surfaceContainerLow: Color(0xFF171D1A),
  surfaceContainer: Color(0xFF1B211F),
  surfaceContainerHigh: Color(0xFF252B29),
  surfaceContainerHighest: Color(0xFF303633),
  onSurfaceVariant: Color(0xFFC1C9BF),
  outline: Color(0xFF8B9389),
  outlineVariant: Color(0xFF414942),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE2E7E1),
  onInverseSurface: Color(0xFF2C322F),
  inversePrimary: Color(0xFF2F6F5E),
  surfaceTint: Color(0xFFA3D2C0),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      FoodIsarSchema,
      MealIsarSchema,
      DiaryEntryIsarSchema,
      UserProfileIsarSchema,
    ],
    directory: dir.path,
  );

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      observers: const [],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(_lightColorScheme),
      darkTheme: _buildTheme(_darkColorScheme),
      home: const DashboardScreen(),
    );
  }
}

ThemeData _buildTheme(ColorScheme colorScheme) {
  final borderRadius = BorderRadius.circular(8);

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: colorScheme.surfaceTint,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      border: OutlineInputBorder(borderRadius: borderRadius),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      dividerColor: colorScheme.outlineVariant,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      actionTextColor: colorScheme.inversePrimary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
