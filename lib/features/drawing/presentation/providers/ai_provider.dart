import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/ai_service.dart';
import '../../domain/models/drawing_point.dart';
import 'drawing_provider.dart';

final aiProvider =
    StateNotifierProvider<AINotifier, AsyncValue<String?>>((ref) {
  return AINotifier();
});

class AINotifier extends StateNotifier<AsyncValue<String?>> {
  AINotifier() : super(const AsyncValue.data(null));

  Future<void> generateImage(DrawingPoints drawingState) async {
    state = const AsyncValue.loading();
    try {
      final imageBytes = await drawingState.toImage();
      final imageUrl = await AIService.generateImage(imageBytes);
      state = AsyncValue.data(imageUrl);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
