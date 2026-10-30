import 'package:flutter/material.dart';

abstract final class RobocekColors {
  static const navy = Color(0xFF0B1220);
  static const navyCard = Color(0xFF131D2F);
  static const blue = Color(0xFF4F8CFF);
  static const cyan = Color(0xFF57D6E6);
  static const green = Color(0xFF3DD598);
  static const amber = Color(0xFFFFC857);
  static const muted = Color(0xFF9BAAC1);
}

ThemeData buildRobocekTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: RobocekColors.blue,
        brightness: Brightness.dark,
      ).copyWith(
        primary: RobocekColors.blue,
        secondary: RobocekColors.cyan,
        surface: RobocekColors.navyCard,
        onSurface: Colors.white,
      );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: RobocekColors.navy,
    useMaterial3: true,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: RobocekColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: RobocekColors.navyCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RobocekColors.navyCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF101A2B),
      indicatorColor: RobocekColors.blue.withValues(alpha: 0.2),
      labelTextStyle: WidgetStatePropertyAll(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: const Color(0xFF101A2B),
      indicatorColor: RobocekColors.blue.withValues(alpha: 0.18),
      tileHeight: 52,
      labelTextStyle: WidgetStatePropertyAll(
        const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
