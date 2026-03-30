import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color divider = Color(0xFF2A2A2A);

  static const Color buildAccent = Color(0xFF42A5F5);
  static const Color avoidAccent = Color(0xFFFFA726);

  static const Color primaryText = Colors.white;
  static const Color secondaryText = Colors.white70;
  static const Color metaText = Colors.white54;

  static const Color disabled = Color(0xFF616161);
  static const Color primaryButtonText = Color(0xFF0D0D0D);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    cardColor: cardBackground,
    dividerColor: divider,
    colorScheme: const ColorScheme.dark(
      primary: buildAccent,
      secondary: avoidAccent,
      surface: cardBackground,
      onPrimary: primaryButtonText,
      onSecondary: primaryText,
      onSurface: primaryText,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: primaryText,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryText),
      titleTextStyle: TextStyle(
        color: primaryText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: const CardThemeData(
      color: cardBackground,
      elevation: 1,
      shadowColor: Colors.black54,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: buildAccent,
      foregroundColor: primaryButtonText,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: background.withValues(alpha: 0.65),
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: divider),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: buildAccent),
      ),
      labelStyle: const TextStyle(color: secondaryText),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: cardBackground,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: background,
      modalBackgroundColor: background,
    ),
    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
    ),
  );
}
