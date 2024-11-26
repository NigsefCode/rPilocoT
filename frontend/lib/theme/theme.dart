import 'package:flutter/material.dart';

class AppTheme {
  // Colores para tema claro (Naranja)
  static const Color primaryColorLight = Color(0xFFFF9800);    // Naranja principal
  static const Color primaryDarkLight = Color(0xFFF57C00);     // Naranja oscuro
  static const Color accentColorLight = Color(0xFFFFB74D);     // Naranja claro
  static const Color backgroundLight = Color(0xFFFAFAFA);      // Fondo muy claro
  static const Color surfaceLight = Colors.white;              // Superficie blanca
  static const Color textPrimaryLight = Color(0xFF212121);     // Texto casi negro
  static const Color textSecondaryLight = Color(0xFF757575);   // Texto gris

  // Colores para tema oscuro (Rosa)
  static const Color primaryColorDark = Color(0xFFE91E63);     // Rosa principal
  static const Color primaryDarkDark = Color(0xFFD81B60);      // Rosa oscuro
  static const Color accentColorDark = Color(0xFFF48FB1);      // Rosa claro
  static const Color backgroundDark = Color(0xFF121212);       // Negro suave
  static const Color surfaceDark = Color(0xFF1E1E1E);         // Gris muy oscuro
  static const Color cardDark = Color(0xFF252525);            // Gris oscuro para tarjetas
  
  // Colores comunes para ambos temas
  static const Color success = Color(0xFF4CAF50);             // Verde éxito
  static const Color error = Color(0xFFE53935);               // Rojo error
  static const Color warning = Color(0xFFFFB74D);             // Naranja advertencia
  static const Color info = Color(0xFF2196F3);                // Azul información

  // Tema Claro
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColorLight,
    colorScheme: ColorScheme.light(
      primary: primaryColorLight,
      secondary: accentColorLight,
      surface: surfaceLight,
      background: backgroundLight,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
      onBackground: textPrimaryLight,
      primaryContainer: primaryColorLight.withOpacity(0.1),
      secondaryContainer: accentColorLight.withOpacity(0.1),
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryColorLight),
    ),
    cardTheme: CardTheme(
      color: surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColorLight,
        side: const BorderSide(color: primaryColorLight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      prefixIconColor: primaryColorLight,
      suffixIconColor: primaryColorLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColorLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: error, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimaryLight),
      bodyMedium: TextStyle(color: textSecondaryLight),
    ),
  );

  // Tema Oscuro
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColorDark,
    colorScheme: ColorScheme.dark(
      primary: primaryColorDark,
      secondary: accentColorDark,
      surface: surfaceDark,
      background: backgroundDark,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      primaryContainer: primaryColorDark.withOpacity(0.12),
      secondaryContainer: accentColorDark.withOpacity(0.12),
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryColorDark),
    ),
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorDark,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColorDark,
        side: const BorderSide(color: primaryColorDark),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      prefixIconColor: primaryColorDark,
      suffixIconColor: primaryColorDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColorDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: error, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.1),
    ),
  );
}
