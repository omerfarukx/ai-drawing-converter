import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/ai_provider.dart';
import '../../../gallery/domain/repositories/gallery_repository.dart';
import '../../../gallery/domain/models/drawing.dart';
import '../widgets/ai_button.dart';
import '../../domain/models/ai_model.dart';

class AIResultDialog extends ConsumerWidget {
  const AIResultDialog({super.key});

  String _getModelLabel(AIModelType type) {
    switch (type) {
      case AIModelType.realistic:
        return 'Gerçekçi';
      case AIModelType.cartoon:
        return 'Karikatür';
      case AIModelType.anime:
        return 'Anime';
      case AIModelType.sketch:
        return 'Karakalem';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiState = ref.watch(aiProvider);
    final selectedModel = ref.watch(selectedModelProvider);

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (aiState.error != null) ...[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                aiState.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ref.read(aiProvider.notifier).clearImage();
                  Navigator.of(context).pop();
                },
                child: const Text('Tamam'),
              ),
            ] else if (aiState.isProcessing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Resim oluşturuluyor...'),
            ] else if (aiState.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(aiState.imageUrl!),
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final galleryRepo = ref.read(galleryRepositoryProvider);
                        final timestamp = DateTime.now();
                        final modelLabel = _getModelLabel(selectedModel);

                        final drawing = Drawing(
                          id: timestamp.millisecondsSinceEpoch.toString(),
                          path: aiState.imageUrl!,
                          category: 'AI',
                          createdAt: timestamp,
                          isAIGenerated: true,
                          title:
                              'AI Çizim (${modelLabel}) ${timestamp.day}/${timestamp.month}/${timestamp.year}',
                          description:
                              '${modelLabel} tarzında yapay zeka ile oluşturulmuş çizim',
                        );

                        await galleryRepo.saveDrawing(drawing);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Resim galeriye kaydedildi'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Hata: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Galeriye Kaydet'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(aiProvider.notifier).clearImage();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Kapat'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
