import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_model.dart';
import '../../domain/models/drawing_points.dart';
import '../../domain/services/ai_service.dart';

final aiProvider =
    StateNotifierProvider<AINotifier, AsyncValue<String?>>((ref) {
  return AINotifier();
});

class AINotifier extends StateNotifier<AsyncValue<String?>> {
  AINotifier() : super(const AsyncValue.data(null));

  Future<String> generateImage(
    DrawingPoints drawingPoints, {
    required AIModel model,
  }) async {
    state = const AsyncValue.loading();

    try {
      final imageBytes = await drawingPoints.toImage();
      final base64Image =
          await AIService.generateImage(imageBytes, model: model);
      state = AsyncValue.data(base64Image);
      return base64Image;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void clearImage() {
    state = const AsyncValue.data(null);
  }
}
