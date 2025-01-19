import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_provider.dart';
import '../providers/ai_credits_provider.dart';
import '../../domain/models/ai_model.dart';
import 'ai_result_dialog.dart';

// Seçilen AI modelini tutmak için provider
final selectedModelProvider =
    StateProvider<AIModelType>((ref) => AIModelType.realistic);

class AiButton extends ConsumerWidget {
  const AiButton({super.key});

  IconData _getModelIcon(AIModelType type) {
    switch (type) {
      case AIModelType.realistic:
        return Icons.view_in_ar; // 3D gerçekçi
      case AIModelType.cartoon:
        return Icons.brush; // Karikatür
      case AIModelType.anime:
        return Icons.face; // Anime yüz
      case AIModelType.sketch:
        return Icons.create; // Karakalem
    }
  }

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
    final credits = ref.watch(aiCreditsProvider);
    final selectedModel = ref.watch(selectedModelProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stil seçici
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: PopupMenuButton<AIModelType>(
              initialValue: selectedModel,
              position: PopupMenuPosition.under,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (AIModelType type) {
                ref.read(selectedModelProvider.notifier).state = type;
              },
              itemBuilder: (BuildContext context) =>
                  AIModelType.values.map((type) {
                return PopupMenuItem<AIModelType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getModelIcon(type),
                        color: type == selectedModel
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getModelLabel(type),
                        style: TextStyle(
                          color: type == selectedModel
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          fontWeight:
                              type == selectedModel ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getModelIcon(selectedModel),
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getModelLabel(selectedModel),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // AI butonu
        Stack(
          children: [
            FloatingActionButton(
              onPressed: aiState.isProcessing || credits <= 0
                  ? null
                  : () async {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => const AIResultDialog(),
                      );

                      try {
                        await ref
                            .read(aiProvider.notifier)
                            .processDrawing(selectedModel);
                      } catch (e) {
                        // Hata durumunda dialog zaten hata mesajını gösterecek
                      }
                    },
              child: aiState.isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.auto_fix_high),
            ),
            // Kredi göstergesi
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: credits > 0 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  credits.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
