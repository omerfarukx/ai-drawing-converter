import 'package:flutter/material.dart';
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

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  static List<CreditPackage> getCreditPackages(
    BuildContext context,
    List<ProductDetails> products,
  ) {
    final packages = [
      (
        credits: 10,
        description: (context) => AppLocalizations.of(context)!.creditPackage10
      ),
      (
        credits: 25,
        description: (context) => AppLocalizations.of(context)!.creditPackage25
      ),
      (
        credits: 50,
        description: (context) => AppLocalizations.of(context)!.creditPackage50
      ),
    ];

    return packages
        .map((p) {
          final productId = PurchaseService.getProductId(p.credits);
          ProductDetails? product;
          try {
            product = products.firstWhere(
              (product) => product.id == productId,
            );
          } catch (_) {
            return null;
          }

          return CreditPackage(
            credits: p.credits,
            productDetails: product,
            getDescription: p.description,
          );
        })
        .whereType<CreditPackage>()
        .toList();
  }

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    final purchaseService = ref.read(purchaseServiceProvider);
    purchaseService.purchaseStream.listen((purchase) {
      // Satın alma başarılı olduğunda kredileri ekle
      final productId = purchase.productID;
      int credits = 0;

      if (productId == PurchaseService.getProductId(10)) {
        credits = 10;
      } else if (productId == PurchaseService.getProductId(25)) {
        credits = 25;
      } else if (productId == PurchaseService.getProductId(50)) {
        credits = 50;
      }

      if (credits > 0) {
        ref.read(aiCreditsProvider.notifier).addCredits(credits);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.purchaseSuccess(credits)),
            ),
          );
        }
      }
    });
  }

  Future<void> _watchAd() async {
    if (_isLoadingAd) return;

    setState(() {
      _isLoadingAd = true;
    });

    try {
      // Ödüllü reklam göster
      final hasRewarded = await AdManager.showRewardedAd();
      if (hasRewarded) {
        // Kullanıcıya 1 hak ekle
        await ref.read(aiCreditsProvider.notifier).addCredits(1);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('1 çizim hakkı kazandınız!'),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAd = false;
        });
      }
    }
  }

  Future<void> _buyCredits(CreditPackage package) async {
    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final productId = PurchaseService.getProductId(package.credits);
      final success = await purchaseService.buyCredits(productId);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.purchaseError),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.error),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final credits = ref.watch(aiCreditsProvider);
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTab),
        actions: [
          // Dil değiştirme butonu
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final newLocale = currentLocale?.languageCode == 'tr'
                  ? const Locale('en')
                  : const Locale('tr');
              ref.read(localeProvider.notifier).state = newLocale;
            },
            tooltip: currentLocale?.languageCode == 'tr' ? 'English' : 'Türkçe',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kalan çizim hakları
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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

              // Reklam izleyerek hak kazanma butonu
              FilledButton.icon(
                onPressed: _isLoadingAd ? null : _watchAd,
                icon: _isLoadingAd
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.video_library),
                label: Text(
                    _isLoadingAd ? l10n.watchAdLoading : l10n.watchAdForCredit),
              ),
              const SizedBox(height: 32),

              // Kredi paketleri
              Text(
                l10n.creditPackages,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              productsAsync.when(
                data: (products) {
                  final creditPackages =
                      ProfilePage.getCreditPackages(context, products);
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: creditPackages.length,
                    itemBuilder: (context, index) {
                      final package = creditPackages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(package.getDescription(context)),
                          subtitle: Text(package.productDetails.price),
                          trailing: FilledButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(l10n.buyNow),
                                  content: Text(l10n
                                      .purchaseConfirmation(package.credits)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(l10n.cancel),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _buyCredits(package);
                                      },
                                      child: Text(l10n.buyNow),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(l10n.buyNow),
                          ),
                        ),
                      );
                    },
                  );
                },
                error: (error, stackTrace) => Text(l10n.error),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
