import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobConfig {
  // ✅ REAL IDs (From your account)
  static const String androidAppOpenId = 'ca-app-pub-1565162979143073/2047431996';
  static const String androidBannerId = 'ca-app-pub-1565162979143073/4560442514';
  static const String androidInterstitialId = 'ca-app-pub-1565162979143073/3247360841';
  static const String androidRewardedId = 'ca-app-pub-1565162979143073/4673595332';
  static const String androidRewardedInterstitialId = 'ca-app-pub-1565162979143073/9051824042';
  static const String androidNativeId = 'ca-app-pub-1565162979143073/3360516664';

  // ✅ TEST IDs (Google Standard)
  static const String testAppOpenId = 'ca-app-pub-3940256099942544/9257395921';
  static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testRewardedInterstitialId = 'ca-app-pub-3940256099942544/5354046379';
  static const String testNativeId = 'ca-app-pub-3940256099942544/2247696110';
}

class AdMobService {
  AdMobService._internal();
  static final AdMobService instance = AdMobService._internal();

  AppOpenAd? _appOpenAd;
  bool _isShowingAppOpenAd = false;
  DateTime? _appOpenLoadTime;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  // ── Initialization ───────────────────────────────────────────────

  Future<void> init() async {
    await MobileAds.instance.initialize();
    loadAppOpenAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  // ── App Open Ad ──────────────────────────────────────────────────

  void loadAppOpenAd({bool useTest = false}) {
    AppOpenAd.load(
      adUnitId: useTest ? AdMobConfig.testAppOpenId : AdMobConfig.androidAppOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('AppOpenAd loaded (${useTest ? "TEST" : "REAL"})');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
          _appOpenAd = null;
          // ✅ Fallback to test ad if real fails
          if (!useTest) {
            debugPrint('🔄 Retrying AppOpenAd with TEST ID...');
            loadAppOpenAd(useTest: true);
          }
        },
      ),
    );
  }

  bool get _isAppOpenAdAvailable => _appOpenAd != null &&
      _appOpenLoadTime != null &&
      DateTime.now().difference(_appOpenLoadTime!) < const Duration(hours: 4);

  Future<void> showAppOpenAdIfAvailable({VoidCallback? onDismissed}) async {
    if (_isShowingAppOpenAd) {
      onDismissed?.call();
      return;
    }
    if (!_isAppOpenAdAvailable) {
      loadAppOpenAd();
      onDismissed?.call();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAppOpenAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
        onDismissed?.call();
      },
    );
    await _appOpenAd!.show();
  }

  /// Special method for Splash screen to wait for the ad
  Future<void> showAppOpenAdOnStart() async {
    int retryCount = 0;
    // Wait up to 5 seconds for the ad to load if it's not ready
    while (!_isAppOpenAdAvailable && retryCount < 5) {
      await Future.delayed(const Duration(seconds: 1));
      retryCount++;
    }

    if (_isAppOpenAdAvailable) {
      Completer<void> completer = Completer<void>();
      await showAppOpenAdIfAvailable(onDismissed: () {
        if (!completer.isCompleted) completer.complete();
      });
      return completer.future;
    }
  }

  // ── Interstitial Ad ──────────────────────────────────────────────

  void loadInterstitialAd({bool useTest = false}) {
    if (_isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: useTest ? AdMobConfig.testInterstitialId : AdMobConfig.androidInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd loaded (${useTest ? "TEST" : "REAL"})');
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
          debugPrint('InterstitialAd failed to load: $error');
          // ✅ Fallback to test ad if real fails
          if (!useTest) {
            debugPrint('🔄 Retrying InterstitialAd with TEST ID...');
            loadInterstitialAd(useTest: true);
          }
        },
      ),
    );
  }

  Future<void> showInterstitialAd({VoidCallback? onDone}) async {
    if (_interstitialAd == null) {
      onDone?.call();
      loadInterstitialAd();
      return;
    }

    final completer = Completer<void>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDone?.call();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDone?.call();
        if (!completer.isCompleted) completer.complete();
      },
    );
    await _interstitialAd!.show();
    return completer.future;
  }

  // ── Rewarded Ad ──────────────────────────────────────────────────

  void loadRewardedAd({bool useTest = false}) {
    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: useTest ? AdMobConfig.testRewardedId : AdMobConfig.androidRewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('RewardedAd loaded (${useTest ? "TEST" : "REAL"})');
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          _rewardedAd = null;
          debugPrint('RewardedAd failed to load: $error');
          // ✅ Fallback to test ad if real fails
          if (!useTest) {
            debugPrint('🔄 Retrying RewardedAd with TEST ID...');
            loadRewardedAd(useTest: true);
          }
        },
      ),
    );
  }

  bool get isRewardedReady => _rewardedAd != null;

  Future<void> showRewardedAd({
    required VoidCallback onReward,
    VoidCallback? onDone,
  }) async {
    if (_rewardedAd == null) {
      onDone?.call();
      loadRewardedAd();
      return;
    }

    final completer = Completer<void>();
    bool earnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        if (earnedReward) {
          onReward();
        }
        onDone?.call();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onDone?.call();
        if (!completer.isCompleted) completer.complete();
      },
    );

    await _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      earnedReward = true;
    });
    return completer.future;
  }
}