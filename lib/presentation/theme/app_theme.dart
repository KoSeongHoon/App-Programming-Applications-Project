import 'package:flutter/material.dart';

class AppTheme {
  // DUNDAM 색상
  static const Color primaryColor = Color(0xFF001F3F); // 진한 파란색
  static const Color accentColor = Color(0xFFFF6B35); // 오렌지
  static const Color backgroundColor = Color(0xFFFAFAFA); // 밝은 배경
  static const Color textColor = Color(0xFF424242); // 어두운 회색
  static const Color lightTextColor = Color(0xFF757575); // 밝은 회색
  static const Color borderColor = Color(0xFFEEEEEE); // 테두리 색

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: accentColor,
        unselectedItemColor: lightTextColor,
        elevation: 8,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: lightTextColor,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderColor),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
