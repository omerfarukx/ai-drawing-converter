import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_model.dart';
import '../../domain/models/drawing_points.dart';
import '../../domain/services/ai_service.dart';
import 'drawing_provider.dart';

final aiLoadingProvider = StateProvider<bool>((ref) => false);

final aiProvider = StateNotifierProvider<AiNotifier, String?>((ref) {
  return AiNotifier(ref);
});

class AiNotifier extends StateNotifier<String?> {
  final Ref _ref;

  AiNotifier(this._ref) : super(null);

  Future<String> generateImage() async {
    try {
      _ref.read(aiLoadingProvider.notifier).state = true;

      final drawingState = _ref.read(drawingProvider);

      // AI modeli oluştur
      final model = AIModel(
        modelType: AIModelType.realistic,
        basePrompt: '''
Transform this sketch into an ultra-realistic photograph. Enhance the sketch with natural lighting, realistic shadows, and fine details. 
Add depth using professional photography techniques, incorporating realistic textures, materials, and surface details. 
Ensure the result is indistinguishable from a professional DSLR camera photo, with perfect exposure, vibrant color grading, and a photorealistic finish.
''',
      );

      // DrawingPoints oluştur
      final drawingPoints = DrawingPoints(
        points: drawingState.points,
        currentPaint: drawingState.currentPaint,
      );

      // Çizimi resme dönüştür
      final imageBytes = await drawingPoints.toImage();

      // AI servisine gönder
      final imageUrl = await AIService.generateImage(imageBytes, model: model);
      state = imageUrl;
      return imageUrl;
    } finally {
      _ref.read(aiLoadingProvider.notifier).state = false;
    }
  }

  void clearImage() {
    state = null;
  }
}
