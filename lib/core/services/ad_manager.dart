import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

class AdManager {
  static Future<void> showInterstitialAd(WidgetRef ref) async {
    try {
      final ad = await AdService.loadInterstitialAd();
      if (ad != null) {
        await ad.show();
      }
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
    }
  }

  static Future<bool> showRewardedAd() async {
    try {
      RewardedAd? rewardedAd;
      bool hasRewarded = false;

      // Reklam yükleme
      rewardedAd = await AdService.loadRewardedAd(
        onUserEarnedReward: (reward) {
          hasRewarded = true;
        },
      );

      if (rewardedAd == null) {
        debugPrint('Failed to load rewarded ad');
        return false;
      }

      // Reklam gösterme
      final result = await AdService.showRewardedAd(
        rewardedAd,
        onUserEarnedReward: (reward) {
          hasRewarded = true;
        },
      );

      return result && hasRewarded;
    } catch (e) {
      debugPrint('Error in showRewardedAd: $e');
      return false;
    }
  }
}
