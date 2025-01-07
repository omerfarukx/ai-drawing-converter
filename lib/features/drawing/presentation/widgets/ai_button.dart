import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ai_provider.dart';
import '../providers/ai_credits_provider.dart';
import 'ai_result_dialog.dart';
import 'purchase_dialog.dart';

class AiButton extends ConsumerWidget {
  const AiButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(aiLoadingProvider);
    final hasCredits = ref.watch(aiCreditsProvider) > 0;

    return FloatingActionButton(
      onPressed: isLoading
          ? null
          : () async {
              if (!hasCredits) {
                // Kredi yoksa satın alma dialogunu göster
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => const PurchaseDialog(),
                  );
                }
                return;
              }

              try {
                // Çizim hakkını kullan
                await ref.read(aiCreditsProvider.notifier).useCredit();

                // AI'ya gönder
                final imageUrl =
                    await ref.read(aiProvider.notifier).generateImage();

                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AiResultDialog(imageUrl: imageUrl),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hata: $e'),
                    ),
                  );
                }
              }
            },
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : !hasCredits
              ? const Icon(Icons.shopping_cart)
              : const Icon(Icons.auto_fix_high),
    );
  }
}
