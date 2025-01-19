import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_model.dart';
import '../../domain/services/ai_service.dart';
import '../../../drawing/presentation/providers/drawing_provider.dart';
import '../providers/ai_credits_provider.dart';

class AIState {
  final bool isProcessing;
  final String? error;
  final String? imageUrl;

  const AIState({
    this.isProcessing = false,
    this.error,
    this.imageUrl,
  });

  AIState copyWith({
    bool? isProcessing,
    String? error,
    String? imageUrl,
  }) {
    return AIState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      imageUrl: imageUrl,
    );
  }
}

class AiNotifier extends StateNotifier<AIState> {
  final StateNotifierProviderRef ref;

  AiNotifier(this.ref) : super(const AIState());

  Future<void> processDrawing(AIModelType modelType) async {
    if (state.isProcessing) return;

    try {
      // Kredi kontrolü
      final creditsNotifier = ref.read(aiCreditsProvider.notifier);
      if (!creditsNotifier.hasCredits) {
        throw AIServiceException('Yetersiz kredi. Lütfen kredi satın alın.');
      }

      state = state.copyWith(isProcessing: true, error: null, imageUrl: null);

      final drawingState = ref.read(drawingProvider);
      if (drawingState.lines.isEmpty) {
        throw AIServiceException('Lütfen önce bir şeyler çizin');
      }

      // Çizimi bir resme dönüştür
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = const Size(1024.0, 1024.0);

      // Beyaz arka plan
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(Offset.zero & size, backgroundPaint);

      // Sabit bir ölçek faktörü kullan
      const scale = 2.5;
      canvas.scale(scale);

      // Her çizgiyi kendi rengi ve kalınlığıyla çiz
      for (final line in drawingState.lines) {
        if (line.isNotEmpty) {
          final path = Path();
          path.moveTo(line.first.point.dx, line.first.point.dy);

          for (var i = 1; i < line.length; i++) {
            path.lineTo(line[i].point.dx, line[i].point.dy);
          }

          // Her çizginin kendi paint'ini kullan
          canvas.drawPath(path, line.first.paint);
        }
      }

      final picture = recorder.endRecording();
      final img =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw AIServiceException('Çizim dönüştürülemedi');

      final pngBytes = byteData.buffer.asUint8List();

      // AI modelini hazırla
      final model = AIModel(
        modelType: modelType,
        basePrompt: '${modelType.prompt}, preserve original colors and style',
      );

      // API'ye gönder
      final base64Image = await AIService.generateImage(pngBytes, model);

      // Resmi kaydet ve URL'i al
      final imagePath = await AIService.saveImage(base64Image);

      // İşlem başarılı olduğunda krediyi düş
      await creditsNotifier.useCredit();

      state = state.copyWith(
        isProcessing: false,
        imageUrl: imagePath,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void clearImage() {
    state = state.copyWith(imageUrl: null, error: null);
  }
}

final aiProvider = StateNotifierProvider<AiNotifier, AIState>((ref) {
  return AiNotifier(ref);
});
