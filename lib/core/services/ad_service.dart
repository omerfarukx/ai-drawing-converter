import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:yapayzeka_cizim/core/services/purchase_service.dart';

class AdService {
  static const int _interstitialFrequency = 5; // Her 5 işlemde bir
  static const int _maxDailyAds = 20; // Günlük maksimum reklam sayısı
  static int _dailyAdCount = 0;
  static DateTime? _lastAdReset;
  static final PurchaseService _purchaseService = PurchaseService();

  // Önbelleğe alınmış reklamlar
  static RewardedAd? _cachedRewardedAd;
  static bool _isLoadingRewardedAd = false;
  static DateTime? _lastRewardedAdLoadTime;

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111' // Test ID
          : 'ca-app-pub-4716033743179769/5155288635'; // Gerçek ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Desteklenmeyen platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4716033743179769/4170581855'; // Gerçek Interstitial ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID (iOS için henüz gerçek ID yok)
    }
    throw UnsupportedError('Desteklenmeyen platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/5224354917' // Test ID
          : 'ca-app-pub-4716033743179769/8636440475'; // Gerçek ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('Desteklenmeyen platform');
  }

  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      // İlk reklamı önceden yükle
      _preloadRewardedAd();
      debugPrint('Mobile Ads initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Mobile Ads: $e');
    }
  }

  // Ödüllü reklamı önceden yükle
  static Future<void> _preloadRewardedAd() async {
    if (_isLoadingRewardedAd || _cachedRewardedAd != null) return;

    _isLoadingRewardedAd = true;
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _cachedRewardedAd = ad;
            _lastRewardedAdLoadTime = DateTime.now();
            _isLoadingRewardedAd = false;
            debugPrint('Rewarded ad preloaded successfully');

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _cachedRewardedAd = null;
                _preloadRewardedAd(); // Yeni reklam yükle
                debugPrint('Rewarded ad dismissed');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _cachedRewardedAd = null;
                _preloadRewardedAd(); // Yeni reklam yükle
                debugPrint('Rewarded ad failed to show: $error');
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('Failed to preload rewarded ad: $error');
            _isLoadingRewardedAd = false;
            // 1 dakika sonra tekrar dene
            Future.delayed(const Duration(minutes: 1), _preloadRewardedAd);
          },
        ),
      );
    } catch (e) {
      debugPrint('Error preloading rewarded ad: $e');
      _isLoadingRewardedAd = false;
    }
  }

  static Future<BannerAd> createBannerAd() async {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner ad loaded: ${ad.responseInfo}'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner ad failed to load: $error');
        },
      ),
    );
  }

  static Future<InterstitialAd?> loadInterstitialAd() async {
    try {
      final completer = Completer<InterstitialAd>();

      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                debugPrint('Interstitial ad failed to show: $error');
              },
            );
            completer.complete(ad);
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial ad failed to load: $error');
            completer.complete(null);
          },
        ),
      );

      return await completer.future;
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      return null;
    }
  }

  static Future<RewardedAd?> loadRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
  }) async {
    // Önbellekteki reklamı kontrol et
    if (_cachedRewardedAd != null) {
      final timeSinceLoad = DateTime.now().difference(_lastRewardedAdLoadTime!);
      if (timeSinceLoad.inHours < 1) {
        // 1 saatten eskiyse yeni reklam yükle
        return _cachedRewardedAd;
      }
    }

    try {
      final completer = Completer<RewardedAd?>();

      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('Rewarded ad loaded successfully');

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('Rewarded ad dismissed');
                ad.dispose();
                _preloadRewardedAd(); // Yeni reklam yükle
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('Rewarded ad failed to show: $error');
                ad.dispose();
                _preloadRewardedAd(); // Yeni reklam yükle
              },
            );

            completer.complete(ad);
          },
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded ad failed to load: $error');
            completer.complete(null);
            _preloadRewardedAd(); // Yeni reklam yüklemeyi dene
          },
        ),
      );

      return await completer.future;
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
      return null;
    }
  }

  static Future<bool> showRewardedAd(
    RewardedAd ad, {
    required Function(RewardItem reward) onUserEarnedReward,
  }) async {
    try {
      final completer = Completer<bool>();

      ad.show(onUserEarnedReward: (_, reward) {
        debugPrint('User earned reward of ${reward.amount} ${reward.type}');
        onUserEarnedReward(reward);
        completer.complete(true);
      });

      return await completer.future;
    } catch (e) {
      debugPrint('Error showing rewarded ad: $e');
      return false;
    }
  }

  static Future<bool> shouldShowAd() async {
    final isPremium = await _purchaseService.isPremium();
    if (isPremium) {
      return false;
    }

    // Günlük reklam sayacını kontrol et ve sıfırla
    final now = DateTime.now();
    if (_lastAdReset == null || !_isSameDay(_lastAdReset!, now)) {
      _dailyAdCount = 0;
      _lastAdReset = now;
    }

    if (_dailyAdCount >= _maxDailyAds) {
      return false;
    }

    return true;
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static Future<void> incrementAdCount() async {
    _dailyAdCount++;
  }

  static bool shouldShowInterstitial(int actionCount) {
    return actionCount % _interstitialFrequency == 0;
  }
}
