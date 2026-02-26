import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeViewModelProvider = NotifierProvider<ThemeViewModel, ThemeMode>(
  ThemeViewModel.new,
);

class ThemeViewModel extends Notifier<ThemeMode> {
  static const String _keyThemeMode = 'theme_mode';
  late final SharedPreferences _prefs;

  @override
  ThemeMode build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    final themeIndex = _prefs.getInt(_keyThemeMode);
    
    if (themeIndex == null) return ThemeMode.system;
    return ThemeMode.values[themeIndex];
  }

  Future<void> toggleTheme(bool isDarkMode) async {
    final mode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    state = mode;
    await _prefs.setInt(_keyThemeMode, mode.index);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setInt(_keyThemeMode, mode.index);
  }
}
