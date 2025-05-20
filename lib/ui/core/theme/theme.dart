import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
    primary: Colors.deepPurple,
    secondary: Colors.purpleAccent,
    surface: Color(0xFF1E1E1E),
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
  ),
  useMaterial3: true,
  dividerColor: Colors.grey.shade700,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
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
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 18),
    bodySmall: TextStyle(color: Colors.white54, fontSize: 14),
    labelLarge: TextStyle(
      color: Colors.purpleAccent,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(color: Colors.grey, fontSize: 12),
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF1E1E1E),
    shadowColor: Colors.black54,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.purpleAccent),
  buttonTheme: const ButtonThemeData(buttonColor: Colors.deepPurple),
);
