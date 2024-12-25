import 'package:flutter/cupertino.dart';

class AppTheme {
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;
  final Color cardColor;

  const AppTheme({
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.accentColor,
    required this.cardColor,
  });

  // Predefined themes
  static const light = AppTheme(
    name: 'Light',
    backgroundColor: CupertinoColors.white,
    textColor: CupertinoColors.black,
    accentColor: CupertinoColors.activeBlue,
    cardColor: Color(0xFFF5F5F5),
  );

  static const dark = AppTheme(
    name: 'Dark',
    backgroundColor: CupertinoColors.black,
    textColor: CupertinoColors.white,
    accentColor: Color(0xFF2196F3),  // Blue
    cardColor: Color(0xFF1C1C1E),
  );

  static const purple = AppTheme(
    name: 'Light Purple',
    backgroundColor: CupertinoColors.white,
    textColor: CupertinoColors.black,
    accentColor: Color(0xFF9C27B0),  // Purple
    cardColor: Color(0xFFF3E5F5),
  );

  static const red = AppTheme(
    name: 'Dark Red',
    backgroundColor: CupertinoColors.black,
    textColor: CupertinoColors.white,
    accentColor: Color(0xFFF44336),  // Red
    cardColor: Color(0xFF1C1C1E),
  );

  static const green = AppTheme(
    name: 'Light Green',
    backgroundColor: CupertinoColors.white,
    textColor: CupertinoColors.black,
    accentColor: Color(0xFF4CAF50),  // Green
    cardColor: Color(0xFFF1F8E9),
  );

  static const orange = AppTheme(
    name: 'Dark Orange',
    backgroundColor: CupertinoColors.black,
    textColor: CupertinoColors.white,
    accentColor: Color(0xFFFF9800),  // Orange
    cardColor: Color(0xFF1C1C1E),
  );

  static const List<AppTheme> presets = [
    light,
    dark,
    purple,
    red,
    green,
    orange,
  ];

  AppTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? accentColor,
    Color? cardColor,
  }) {
    return AppTheme(
      name: this.name,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      accentColor: accentColor ?? this.accentColor,
      cardColor: cardColor ?? this.cardColor,
    );
  }
}