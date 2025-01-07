import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/purchase_provider.dart';

class PurchaseDialog extends ConsumerWidget {
  const PurchaseDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(purchaseLoadingProvider);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI Çizim Kredisi Satın Al',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '10 AI çizim kredisi satın alarak çizimlerinizi AI ile geliştirin.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const CircularProgressIndicator()
            else
              FilledButton(
                onPressed: () async {
                  ref.read(purchaseLoadingProvider.notifier).state = true;
                  try {
                    await ref.read(purchaseServiceProvider).buyCredits();
                  } finally {
                    ref.read(purchaseLoadingProvider.notifier).state = false;
                  }
                },
                child: const Text('Satın Al (₺9.99)'),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
          ],
        ),
      ),
    );
  }
}
