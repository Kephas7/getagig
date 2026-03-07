import 'package:flutter/material.dart';

const Color _lightBackground = Color(0xFFF6F7FB);
const Color _lightSurface = Color(0xFFFFFFFF);
const Color _lightMuted = Color(0xFFF1F3F8);
const Color _lightBorder = Color(0xFFDCE1EB);
const Color _lightPrimary = Color(0xFF1B2A4A);
const Color _lightSpotlight = Color(0xFF3B82F6);

const Color _darkBackground = Color(0xFF10131A);
const Color _darkSurface = Color(0xFF171B24);
const Color _darkMuted = Color(0xFF202634);
const Color _darkBorder = Color(0xFF2D3444);
const Color _darkPrimary = Color(0xFFE8EEF9);
const Color _darkSpotlight = Color(0xFF7AB0FF);

ThemeData getLightTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: _lightSpotlight,
        brightness: Brightness.light,
      ).copyWith(
        primary: _lightPrimary,
        onPrimary: Colors.white,
        secondary: _lightSpotlight,
        onSecondary: Colors.white,
        surface: _lightSurface,
        onSurface: const Color(0xFF171717),
        error: const Color(0xFFDC2626),
        onError: Colors.white,
      );

  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: _lightBackground,
    fontFamily: 'Urbanist-Medium',
    colorScheme: colorScheme,
    dividerColor: _lightBorder,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: _lightPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Urbanist-Bold',
      ),
      iconTheme: IconThemeData(color: _lightPrimary),
    ),
    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _lightBorder),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightSurface,
      selectedItemColor: _lightPrimary,
      unselectedItemColor: Color(0xFF6B7280),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        fontFamily: 'Urbanist-SemiBold',
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _lightMuted,
      selectedColor: _lightSpotlight.withValues(alpha: 0.14),
      side: const BorderSide(color: _lightBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: const TextStyle(
        color: _lightPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _lightPrimary,
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Urbanist-Bold',
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightSpotlight,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Urbanist-SemiBold',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _lightBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _lightSpotlight, width: 2),
      ),
      contentPadding: const EdgeInsets.all(18),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1B2A4A),
      contentTextStyle: const TextStyle(
        color: Color(0xFFF8FAFC),
        fontFamily: 'Urbanist-Medium',
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

ThemeData getDarkTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: _darkSpotlight,
        brightness: Brightness.dark,
      ).copyWith(
        primary: _darkPrimary,
        onPrimary: const Color(0xFF10131A),
        secondary: _darkSpotlight,
        onSecondary: const Color(0xFF0E1118),
        surface: _darkSurface,
        onSurface: const Color(0xFFEAF0FA),
        error: const Color(0xFFF87171),
        onError: const Color(0xFF0E1118),
      );

  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: _darkBackground,
    fontFamily: 'Urbanist-Medium',
    colorScheme: colorScheme,
    dividerColor: _darkBorder,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: _darkPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Urbanist-Bold',
      ),
      iconTheme: IconThemeData(color: _darkPrimary),
    ),
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _darkBorder),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _darkPrimary,
      unselectedItemColor: Color(0xFF9AA4B7),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        fontFamily: 'Urbanist-SemiBold',
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkMuted,
      selectedColor: _darkSpotlight.withValues(alpha: 0.2),
      side: const BorderSide(color: _darkBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: const TextStyle(
        color: _darkPrimary,
        fontWeight: FontWeight.w700,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF0E1118),
        backgroundColor: _darkPrimary,
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Urbanist-Bold',
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkSpotlight,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Urbanist-SemiBold',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _darkBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _darkSpotlight, width: 2),
      ),
      contentPadding: const EdgeInsets.all(18),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFFEAF0FA),
      contentTextStyle: const TextStyle(
        color: Color(0xFF0E1118),
        fontFamily: 'Urbanist-Medium',
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

ThemeData getApplicationTheme() => getLightTheme();
