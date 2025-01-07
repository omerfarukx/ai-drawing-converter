import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final aiCreditsProvider = StateNotifierProvider<AiCreditsNotifier, int>((ref) {
  return AiCreditsNotifier();
});

class AiCreditsNotifier extends StateNotifier<int> {
  AiCreditsNotifier() : super(3) {
    // Başlangıçta 3 hak
    _loadCredits();
  }

  static const String _creditsKey = 'ai_credits';
  static const int _maxFreeCredits = 3;

  Future<void> _loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_creditsKey) ?? _maxFreeCredits;
  }

  Future<void> useCredit() async {
    if (state > 0) {
      final prefs = await SharedPreferences.getInstance();
      state = state - 1;
      await prefs.setInt(_creditsKey, state);
    }
  }

  Future<void> addCredits(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    state = state + amount;
    await prefs.setInt(_creditsKey, state);
  }

  Future<void> resetCredits() async {
    final prefs = await SharedPreferences.getInstance();
    state = _maxFreeCredits;
    await prefs.setInt(_creditsKey, state);
  }

  bool get hasCredits => state > 0;
}
