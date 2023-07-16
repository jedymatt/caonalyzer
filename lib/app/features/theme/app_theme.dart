import 'package:flutter/material.dart';

abstract class AppThemeData {
  static ThemeData lightPrimary = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
    ),
    useMaterial3: true,
  );

  static ThemeData darkPrimary = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static ThemeData lightBlue = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
    ),
    useMaterial3: true,
  );

  static ThemeData darkBlue = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static ThemeData lightOrange = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
    ),
    useMaterial3: true,
  );

  static ThemeData darkOrange = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static ThemeData lightGreen = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
    ),
    useMaterial3: true,
  );

  static ThemeData darkGreen = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static ThemeData lightRed = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
    ),
    useMaterial3: true,
  );

  static ThemeData darkRed = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static ThemeData lightYellow = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.yellow,
    ),
    useMaterial3: true,
  );

  static ThemeData darkYellow = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.yellow,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}

enum AppTheme {
  lightPrimary,
  darkPrimary,
  lightBlue,
  darkBlue,
  lightOrange,
  darkOrange,
  lightGreen,
  darkGreen,
  lightRed,
  darkRed,
  lightYellow,
  darkYellow;

  ThemeData get themeData {
    switch (this) {
      case AppTheme.lightPrimary:
        return AppThemeData.lightPrimary;
      case AppTheme.darkPrimary:
        return AppThemeData.darkPrimary;
      case AppTheme.lightBlue:
        return AppThemeData.lightBlue;
      case AppTheme.darkBlue:
        return AppThemeData.darkBlue;
      case AppTheme.lightOrange:
        return AppThemeData.lightOrange;
      case AppTheme.darkOrange:
        return AppThemeData.darkOrange;
      case AppTheme.lightGreen:
        return AppThemeData.lightGreen;
      case AppTheme.darkGreen:
        return AppThemeData.darkGreen;
      case AppTheme.lightRed:
        return AppThemeData.lightRed;
      case AppTheme.darkRed:
        return AppThemeData.darkRed;
      case AppTheme.lightYellow:
        return AppThemeData.lightYellow;
      case AppTheme.darkYellow:
        return AppThemeData.darkYellow;
      default:
        return AppThemeData.lightPrimary;
    }
  }

  bool get isDark =>
      this == AppTheme.darkPrimary ||
      this == AppTheme.darkBlue ||
      this == AppTheme.darkOrange ||
      this == AppTheme.darkGreen ||
      this == AppTheme.darkRed ||
      this == AppTheme.darkYellow;

  AppTheme get light {
    switch (this) {
      case AppTheme.darkPrimary:
        return AppTheme.lightPrimary;
      case AppTheme.darkBlue:
        return AppTheme.lightBlue;
      case AppTheme.darkOrange:
        return AppTheme.lightOrange;
      case AppTheme.darkGreen:
        return AppTheme.lightGreen;
      case AppTheme.darkRed:
        return AppTheme.lightRed;
      case AppTheme.darkYellow:
        return AppTheme.lightYellow;
      default:
        return AppTheme.lightPrimary;
    }
  }

  AppTheme get dark {
    switch (this) {
      case AppTheme.lightPrimary:
        return AppTheme.darkPrimary;
      case AppTheme.lightBlue:
        return AppTheme.darkBlue;
      case AppTheme.lightOrange:
        return AppTheme.darkOrange;
      case AppTheme.lightGreen:
        return AppTheme.darkGreen;
      case AppTheme.lightRed:
        return AppTheme.darkRed;
      case AppTheme.lightYellow:
        return AppTheme.darkYellow;
      default:
        return AppTheme.darkPrimary;
    }
  }
}
