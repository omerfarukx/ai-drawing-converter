import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_model.dart';
import '../../domain/models/drawing_points.dart';
import '../providers/ai_provider.dart';
import '../providers/drawing_provider.dart';
import 'ai_result_dialog.dart';

class AIButton extends ConsumerWidget {
  const AIButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiProvider);
    final drawingState = ref.watch(drawingProvider);

    return FloatingActionButton(
      onPressed: aiState.isLoading || drawingState.points.isEmpty
          ? null
          : () async {
              try {
                final drawingState = ref.read(drawingProvider);

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

                // Resmi oluştur
                final imageUrl =
                    await ref.read(aiProvider.notifier).generateImage(
                          drawingPoints,
                          model: model,
                        );

                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AIResultDialog(imageUrl: imageUrl),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
      child: aiState.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.auto_awesome),
    );
  }
}
