import 'package:flutter/material.dart';

abstract final class RobocekColors {
  static const navy = Color(0xFF281319);
  static const navyCard = Color(0xFF3B1D27);
  static const blue = Color(0xFF7B1E3A);
  static const cyan = Color(0xFFF3E6C8);
  static const green = Color(0xFF3DD598);
  static const amber = Color(0xFFC9A66B);
  static const line = Color(0xFF8F6B4A);
  static const muted = Color(0xFFD6C2B0);
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
        onSurface: RobocekColors.cyan,
      );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: RobocekColors.navy,
    useMaterial3: true,
    fontFamily: 'Roboto',
    dividerColor: RobocekColors.line.withValues(alpha: 0.55),
    appBarTheme: const AppBarTheme(
      backgroundColor: RobocekColors.navy,
      foregroundColor: RobocekColors.cyan,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: RobocekColors.navyCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: RobocekColors.line.withValues(alpha: 0.45)),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RobocekColors.navyCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: RobocekColors.line.withValues(alpha: 0.6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: RobocekColors.line.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: RobocekColors.cyan, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: RobocekColors.navyCard,
      indicatorColor: RobocekColors.blue.withValues(alpha: 0.2),
      labelTextStyle: WidgetStatePropertyAll(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: RobocekColors.navyCard,
      indicatorColor: RobocekColors.blue.withValues(alpha: 0.18),
      tileHeight: 52,
      labelTextStyle: WidgetStatePropertyAll(
        const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
