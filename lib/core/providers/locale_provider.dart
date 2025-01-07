import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('tr')) {
    _loadSavedLocale();
  }

  static const String _localeKey = 'locale';
  final _prefs = SharedPreferences.getInstance();

  Future<void> _loadSavedLocale() async {
    final prefs = await _prefs;
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = await _prefs;
    await prefs.setString(_localeKey, languageCode);
    state = Locale(languageCode);
  }
}
