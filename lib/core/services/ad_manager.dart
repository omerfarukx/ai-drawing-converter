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
  bool _isRewardedAdLoading = false;

  // Test reklam ID'leri
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // Gerçek reklam ID'leri
  static const String _prodRewardedAdUnitId =
      'ca-app-pub-4716033743179769/863644047';
  static const String _prodBannerAdUnitId =
      'ca-app-pub-4716033743179769/5155288635';
  static const String _prodInterstitialAdUnitId =
      'ca-app-pub-4716033743179769/417058185';

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      return _testRewardedAdUnitId;
    }
    return _prodRewardedAdUnitId;
  }

  static String get bannerAdUnitId {
    if (kDebugMode) {
      return _testBannerAdUnitId;
    }
    return _prodBannerAdUnitId;
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return _testInterstitialAdUnitId;
    }
    return _prodInterstitialAdUnitId;
  }

  Future<void> initialize() async {
    if (!kDebugMode) {
      await MobileAds.instance.initialize();
      await _loadRewardedAd();
    }
  }

  Future<void> _loadRewardedAd() async {
    if (_isRewardedAdLoading || _rewardedAd != null) return;

    _isRewardedAdLoading = true;

    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('Reklam yüklenemedi: $error');
            _rewardedAd = null;
            _isRewardedAdLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('Reklam yüklenirken hata: $e');
      _rewardedAd = null;
      _isRewardedAdLoading = false;
    }
  }

  Future<bool> showRewardedAd() async {
    if (kDebugMode) {
      // Debug modunda her zaman başarılı
      debugPrint('Debug modunda test reklam gösterimi');
      return true;
    }

    if (_rewardedAd == null) {
      await _loadRewardedAd();
      if (_rewardedAd == null) return false;
    }

    bool isRewarded = false;
    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          isRewarded = true;
        },
      );
    } catch (e) {
      debugPrint('Reklam gösterilirken hata: $e');
      return false;
    } finally {
      _rewardedAd = null;
      _loadRewardedAd(); // Bir sonraki gösterim için yeni reklam yükle
    }

    return isRewarded;
  }

  void dispose() {
    _rewardedAd?.dispose();
  }

  static Future<void> showInterstitialAd(WidgetRef ref) async {
    if (kDebugMode) {
      debugPrint('Debug modunda test geçiş reklamı gösterimi');
      return;
    }

    try {
      final ad = await AdService.loadInterstitialAd();
      if (ad != null) {
        await ad.show();
      }
    } catch (e) {
      debugPrint('Geçiş reklamı gösterilirken hata: $e');
    }
  }
}
