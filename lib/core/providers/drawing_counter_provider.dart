import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final drawingCounterProvider =
    StateNotifierProvider<DrawingCounterNotifier, int>((ref) {
  return DrawingCounterNotifier();
});

class DrawingCounterNotifier extends StateNotifier<int> {
  DrawingCounterNotifier() : super(0) {
    _loadCounter();
  }

  static const String _counterKey = 'drawing_counter';
  final _prefs = SharedPreferences.getInstance();

  Future<void> _loadCounter() async {
    final prefs = await _prefs;
    state = prefs.getInt(_counterKey) ?? 0;
  }

  Future<void> increment() async {
    final prefs = await _prefs;
    state = state + 1;
    await prefs.setInt(_counterKey, state);
  }

  Future<void> reset() async {
    final prefs = await _prefs;
    state = 0;
    await prefs.setInt(_counterKey, state);
  }
}
