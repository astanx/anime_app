import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  fontFamily: 'NotoSans',
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121111),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
    primary: Colors.deepPurple,
    secondary: Color(0xFFAD1CB4),
    surface: Color(0xFF332525),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
  ),
  useMaterial3: true,
  dividerColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  listTileTheme: const ListTileThemeData(iconColor: Colors.white),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(color: Colors.white, fontSize: 18),
    bodySmall: TextStyle(color: Colors.white, fontSize: 14),
    labelLarge: TextStyle(
      color: Colors.purpleAccent,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(color: Colors.white, fontSize: 10),
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF332525),
    shadowColor: Colors.black54,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  buttonTheme: const ButtonThemeData(buttonColor: Colors.deepPurple),
);
