import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/services/ad_manager.dart';
import '../../../../core/services/purchase_service.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/purchase_provider.dart';
import '../../../drawing/presentation/providers/ai_credits_provider.dart';

final productsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final purchaseService = ref.read(purchaseServiceProvider);
  return purchaseService.getProducts();
});

class CreditPackage {
  final int credits;
  final ProductDetails productDetails;
  final String Function(BuildContext) getDescription;

  const CreditPackage({
    required this.credits,
    required this.productDetails,
    required this.getDescription,
  });
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = ref.watch(aiCreditsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTab),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kalan krediler
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.remainingCredits,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.credits(credits),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reklam izleme butonu
              FilledButton.icon(
                onPressed: () async {
                  // Reklam izleme işlemi başarılı olduğunda
                  await ref.read(aiCreditsProvider.notifier).addCredits(1);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('1 çizim hakkı kazandınız!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.video_library),
                label: Text(l10n.watchAdForCredit),
              ),
              const SizedBox(height: 32),

              // Kredi paketleri (sadece debug modda)
              if (kDebugMode) ...[
                Text(
                  l10n.creditPackages,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Test paketleri
                _buildTestPackage(
                  context: context,
                  ref: ref,
                  credits: 10,
                  price: '₺9.99',
                ),
                const SizedBox(height: 8),
                _buildTestPackage(
                  context: context,
                  ref: ref,
                  credits: 25,
                  price: '₺19.99',
                ),
                const SizedBox(height: 8),
                _buildTestPackage(
                  context: context,
                  ref: ref,
                  credits: 50,
                  price: '₺39.99',
                  hasBonus: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestPackage({
    required BuildContext context,
    required WidgetRef ref,
    required int credits,
    required String price,
    bool hasBonus = false,
  }) {
    return Card(
      child: ListTile(
        title: Text('$credits Kredi${hasBonus ? ' + 5 Bonus' : ''}'),
        subtitle: Text(price),
        trailing: FilledButton(
          onPressed: () async {
            // Test satın alma işlemi
            await ref
                .read(aiCreditsProvider.notifier)
                .addCredits(credits + (hasBonus ? 5 : 0));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '$credits kredi${hasBonus ? ' + 5 bonus' : ''} satın alındı!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Satın Al'),
        ),
      ),
    );
  }
}
