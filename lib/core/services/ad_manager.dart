import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static String get bannerAdUnitId {
    return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  }

  static String get interstitialAdUnitId {
    return 'ca-app-pub-4716033743179769/4170581855';
  }

  static String get rewardedAdUnitId {
    return 'ca-app-pub-4716033743179769/8636440475';
  }

  static bool shouldShowInterstitial(int drawingCount) {
    return drawingCount % 5 == 0; // Her 5 çizimde bir
  }

  static Future<void> showInterstitialAd(WidgetRef ref) async {
    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          ad.show();
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  static Future<bool> showRewardedAd() async {
    Completer<bool> rewardCompleter = Completer<bool>();
    RewardedAd? rewardedAd;

    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            rewardedAd = ad;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                if (!rewardCompleter.isCompleted) {
                  rewardCompleter.complete(false);
                }
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                if (!rewardCompleter.isCompleted) {
                  rewardCompleter.complete(false);
                }
              },
            );
            ad.show(
              onUserEarnedReward: (ad, reward) {
                if (!rewardCompleter.isCompleted) {
                  rewardCompleter.complete(true);
                }
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('Rewarded ad failed to load: $error');
            if (!rewardCompleter.isCompleted) {
              rewardCompleter.complete(false);
            }
          },
        ),
      );

      return await rewardCompleter.future;
    } catch (e) {
      print('Error showing rewarded ad: $e');
      if (!rewardCompleter.isCompleted) {
        rewardCompleter.complete(false);
      }
      return false;
    }
  }
}
