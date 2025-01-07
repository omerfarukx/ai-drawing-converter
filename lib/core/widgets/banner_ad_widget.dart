import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/ad_provider.dart';

class BannerAdWidget extends ConsumerWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adAsync = ref.watch(bannerAdProvider);

    return SizedBox(
      height: 50,
      child: adAsync.when(
        data: (ad) => AdWidget(ad: ad),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}
