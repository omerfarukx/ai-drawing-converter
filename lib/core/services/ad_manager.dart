import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();

  factory AdManager() {
    return _instance;
  }

  AdManager._internal();

  RewardedAd? _rewardedAd;

  // Test reklam ID'leri
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  // Gerçek reklam ID'leri
  static const String _prodRewardedAdUnitId =
      'YOUR_REWARDED_AD_UNIT_ID'; // TODO: Gerçek reklam ID'nizi ekleyin

  String get _rewardedAdUnitId {
    if (kDebugMode) {
      return _testRewardedAdUnitId;
    } else {
      return _prodRewardedAdUnitId;
    }
  }

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadRewardedAd();

    // Test cihazları ekleyin (debug modunda)
    if (kDebugMode) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [
          'TEST_DEVICE_ID'
        ]), // TODO: Test cihaz ID'nizi ekleyin
      );
    }
  }

  Future<void> _loadRewardedAd() async {
    try {
      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            print('Reklam başarıyla yüklendi');
          },
          onAdFailedToLoad: (error) {
            print('Reklam yüklenemedi: $error');
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      print('Reklam yüklenirken hata: $e');
      _rewardedAd = null;
    }
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      await _loadRewardedAd();
      if (_rewardedAd == null) {
        if (kDebugMode) {
          print('Debug modunda test kredisi veriliyor');
          return true; // Debug modunda her zaman kredi ver
        }
        return false;
      }
    }

    bool isRewarded = false;
    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          isRewarded = true;
        },
      );
    } catch (e) {
      print('Reklam gösterilirken hata: $e');
      if (kDebugMode) {
        isRewarded = true; // Debug modunda hata olsa bile kredi ver
      }
    }

    _rewardedAd = null;
    await _loadRewardedAd();

    return isRewarded;
  }

  void dispose() {
    _rewardedAd?.dispose();
  }

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
}
