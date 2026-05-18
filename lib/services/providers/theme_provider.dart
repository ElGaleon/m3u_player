import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3u_player/services/providers/path_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  late final SharedPreferences _preferences;
  static const _key = "theme";

  @override
  ThemeMode build() {
    _preferences = ref.watch(sharedPreferencesProvider);
    return _parseStringToThemeMode(_preferences.getString(_key) ?? 'system');
  }

  Future<void> updateTheme(ThemeMode newValue) async {
    await _preferences.setString(_key, newValue.name);
    state = newValue;
  }

  ThemeMode _parseStringToThemeMode(String newValue) {
    return switch (newValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
