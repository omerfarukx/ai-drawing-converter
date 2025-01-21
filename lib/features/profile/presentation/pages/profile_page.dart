import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/services/ad_manager.dart';
import '../../../../core/providers/purchase_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../drawing/presentation/providers/ai_credits_provider.dart';
import '../../domain/services/social_service.dart';
import '../../domain/models/user_profile_model.dart';
import '../../../../core/services/auth_service.dart';
import '../providers/social_provider.dart';
import '../widgets/profile_stats_widget.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_drawings_grid.dart';
import '../widgets/special_offers_widget.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Profil verilerini yenile
          ref.refresh(currentUserProfileProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Profil başlığı (avatar, isim, bio)
              Consumer(
                builder: (context, ref, child) {
                  final profileAsync = ref.watch(currentUserProfileProvider);

                  return profileAsync.when(
                    data: (profile) => ProfileHeaderWidget(profile: profile),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Hata: $error'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // İstatistikler (çizimler, takipçiler, takip edilenler)
              Consumer(
                builder: (context, ref, child) {
                  final profileAsync = ref.watch(currentUserProfileProvider);

                  return profileAsync.when(
                    data: (profile) => ProfileStatsWidget(profile: profile),
                    loading: () => const SizedBox(height: 80),
                    error: (_, __) => const SizedBox(height: 80),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Özel teklifler
              const SpecialOffersWidget(),

              const SizedBox(height: 16),

              // Çizim galerisi
              Consumer(
                builder: (context, ref, child) {
                  final profileAsync = ref.watch(currentUserProfileProvider);

                  return profileAsync.when(
                    data: (profile) => ProfileDrawingsGrid(userId: profile.id),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Hata: $error'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleWatchAd(WidgetRef ref) async {
    final adManager = AdManager();
    final creditsNotifier = ref.read(aiCreditsProvider.notifier);

    if (await adManager.showRewardedAd()) {
      await creditsNotifier.addCredits(1); // Reklam izleme başına 1 kredi
    }
  }

  void _handlePurchase(WidgetRef ref, ProductDetails product) async {
    final purchaseService = ref.read(purchaseServiceProvider);
    final creditsNotifier = ref.read(aiCreditsProvider.notifier);

    try {
      final success = await purchaseService.buyProduct(product.id);
      if (success) {
        // Kredi miktarı ürün ID'sine göre belirlenir
        switch (product.id) {
          case 'credits_10':
            await creditsNotifier.addCredits(10);
            break;
          case 'credits_25':
            await creditsNotifier.addCredits(25);
            break;
          case 'credits_50':
            await creditsNotifier.addCredits(55); // 50 + 5 bonus
            break;
          case 'credits_100':
            await creditsNotifier.addCredits(115); // 100 + 15 bonus
            break;
        }
      }
    } catch (e) {
      print('Satın alma hatası: $e');
    }
  }
}

class _CreditPackageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final ProductDetails product;
  final bool isPopular;
  final Function(ProductDetails) onTap;
  final bool showBonus;
  final String bonusAmount;

  const _CreditPackageCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.product,
    this.isPopular = false,
    required this.onTap,
    this.showBonus = false,
    this.bonusAmount = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPopular
              ? const [Color(0xFF533483), Color(0xFF0F3460)]
              : const [Color(0xFF16213E), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(product),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'En Popüler',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (showBonus)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE94560).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Bonus $bonusAmount',
                      style: const TextStyle(
                        color: Color(0xFFE94560),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
