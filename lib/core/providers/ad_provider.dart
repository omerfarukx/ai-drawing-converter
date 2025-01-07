import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

final bannerAdProvider = FutureProvider.autoDispose<BannerAd>((ref) async {
  final ad = await AdService.createBannerAd();
  await ad.load();
  ref.onDispose(() => ad.dispose());
  return ad;
});

final interstitialAdProvider =
    FutureProvider.autoDispose<InterstitialAd?>((ref) async {
  final ad = await AdService.loadInterstitialAd();
  ref.onDispose(() => ad?.dispose());
  return ad;
});

final rewardedAdProvider = FutureProvider.family
    .autoDispose<RewardedAd?, Function(RewardItem)>((ref, onReward) async {
  final ad = await AdService.loadRewardedAd(onUserEarnedReward: onReward);
  ref.onDispose(() => ad?.dispose());
  return ad;
});
