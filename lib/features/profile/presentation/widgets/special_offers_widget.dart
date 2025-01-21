import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/providers/purchase_provider.dart';
import '../../../drawing/presentation/providers/ai_credits_provider.dart';
import '../../../../core/services/ad_manager.dart';

class SpecialOffersWidget extends ConsumerWidget {
  const SpecialOffersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Reklam ile Kredi Kazanma
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber, width: 2),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.video_library_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ücretsiz Kredi Kazan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Reklam izleyerek 1 kredi kazanın',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _handleWatchAd(ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('İzle'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Kredi Paketleri
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.deepPurple, Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Kredi Paketleri',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCreditPackage(
                    ref: ref,
                    credits: 10,
                    price: '₺29.99',
                    productId: 'credits_10',
                    isPopular: false,
                  ),
                  _buildCreditPackage(
                    ref: ref,
                    credits: 25,
                    price: '₺59.99',
                    productId: 'credits_25',
                    isPopular: true,
                  ),
                  _buildCreditPackage(
                    ref: ref,
                    credits: 50,
                    price: '₺99.99',
                    productId: 'credits_50',
                    isPopular: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditPackage({
    required WidgetRef ref,
    required int credits,
    required String price,
    required String productId,
    required bool isPopular,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handlePurchase(ref, productId),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPopular ? Colors.amber : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              if (isPopular) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Popüler',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                '$credits',
                style: TextStyle(
                  color: isPopular ? Colors.black : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Kredi',
                style: TextStyle(
                  color: isPopular ? Colors.black87 : Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: TextStyle(
                  color: isPopular ? Colors.black : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleWatchAd(WidgetRef ref) async {
    final adManager = AdManager();
    final creditsNotifier = ref.read(aiCreditsProvider.notifier);

    if (await adManager.showRewardedAd()) {
      await creditsNotifier.addCredits(1); // Reklam izleme başına 1 kredi
    }
  }

  Future<void> _handlePurchase(WidgetRef ref, String productId) async {
    final purchaseService = ref.read(purchaseServiceProvider);
    final creditsNotifier = ref.read(aiCreditsProvider.notifier);

    try {
      final success = await purchaseService.buyProduct(productId);
      if (success) {
        switch (productId) {
          case 'credits_10':
            await creditsNotifier.addCredits(10);
            break;
          case 'credits_25':
            await creditsNotifier.addCredits(25);
            break;
          case 'credits_50':
            await creditsNotifier.addCredits(50);
            break;
          case 'credits_100':
            await creditsNotifier.addCredits(100);
            break;
        }
      }
    } catch (e) {
      debugPrint('Satın alma hatası: $e');
    }
  }
}
