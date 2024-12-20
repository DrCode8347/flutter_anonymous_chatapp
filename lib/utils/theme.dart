import 'package:flutter/material.dart';

class AppTheme {
  // TITLE TEXT THEMES/STYLES
  static final LabelText = TextStyle(
    color: Colors.white60,
    fontSize: 16,
    fontFamily: 'poppins',
  );
  static final TitleText = TextStyle(
      color: Colors.white60,
      fontSize: 34,
      fontFamily: 'poppins',
      fontWeight: FontWeight.bold);
  static final SubtitleText = TextStyle(
      color: Colors.white60,
      fontSize: 24,
      fontFamily: 'poppins',
      fontWeight: FontWeight.bold);
  static final Subtitlesmall = TextStyle(
      color: Colors.white60,
      fontSize: 18,
      fontFamily: 'poppins',
      fontWeight: FontWeight.bold);
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF006A4E), // Hooke's Green
    scaffoldBackgroundColor:
        const Color.fromARGB(255, 19, 19, 19), // Charcoal Gray
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // Hooke's Green
      titleTextStyle: TextStyle(color: Colors.white60, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white60),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          color: Colors.white60,
          fontSize: 16,
          fontFamily: 'poppins',
          fontWeight: FontWeight.bold), // Text Color
      bodyMedium:
          TextStyle(color: Colors.white70, fontFamily: 'poppins', fontSize: 14),
      bodySmall: TextStyle(
          color: Colors.white54,
          fontFamily: 'poppins',
          fontSize: 12), // For less emphasized text
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFE97451), // Burnt Sienna
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFFE97451), // Burnt Sienna
      textTheme: ButtonTextTheme.primary,
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF006A4E), // Hooke's Green
      secondary: Color(0xFFE97451), // Charcoal Gray
      surface: Colors.white60, // Slightly darker for components like cards
      onSurface: Colors.white60, // Text color on surfaces
      onPrimary: Colors.white60, // Text color on primary
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white60, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      hintStyle: TextStyle(color: Colors.white60),
      focusedBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: Color(0xFF006A4E)), // Burnt Sienna for focus
      ),
    ),
    cardTheme: const CardTheme(
      color: Color.fromARGB(
          252, 44, 44, 44), // Dark card background to match the theme
      shadowColor: Colors.black,
      elevation: 4,
    ),
  );
}
