// lib/theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    hintColor: Colors.blueAccent,
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blueAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: TextTheme(
      headlineLarge: const TextStyle(
          color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.grey[300]),
      bodyMedium: TextStyle(color: Colors.grey[500]),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.grey[500]),
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
