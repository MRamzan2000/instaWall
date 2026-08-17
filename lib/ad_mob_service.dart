import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobConfig {
  static const bool useTestAds = true;

  // IDs from screenshots
  static const String androidAppOpenId = 'ca-app-pub-1565162979143073/2047431996';
  static const String androidBannerId = 'ca-app-pub-1565162979143073/4560442514';
  static const String androidInterstitialId = 'ca-app-pub-1565162979143073/3247360841';
  static const String androidRewardedId = 'ca-app-pub-1565162979143073/4673595332';
  static const String androidRewardedInterstitialId = 'ca-app-pub-1565162979143073/9051824042';
  static const String androidNativeId = 'ca-app-pub-1565162979143073/3360516664';

  static String get appOpenAdUnitId => useTestAds ? 'ca-app-pub-3940256099942544/9257395921' : androidAppOpenId;
  static String get bannerAdUnitId => useTestAds ? 'ca-app-pub-3940256099942544/6300978111' : androidBannerId;
  static String get interstitialAdUnitId => useTestAds ? 'ca-app-pub-3940256099942544/1033173712' : androidInterstitialId;
  static String get rewardedAdUnitId => useTestAds ? 'ca-app-pub-3940256099942544/5224354917' : androidRewardedId;
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

  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: AdMobConfig.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  bool get _isAppOpenAdAvailable => _appOpenAd != null &&
      _appOpenLoadTime != null &&
      DateTime.now().difference(_appOpenLoadTime!) < const Duration(hours: 4);

  void showAppOpenAdIfAvailable() {
    if (_isShowingAppOpenAd) return;
    if (!_isAppOpenAdAvailable) {
      loadAppOpenAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => _isShowingAppOpenAd = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
  }

  // ── Interstitial Ad ──────────────────────────────────────────────

  void loadInterstitialAd() {
    if (_isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
          debugPrint('InterstitialAd failed to load: $error');
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

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDone?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDone?.call();
      },
    );
    _interstitialAd!.show();
  }

  // ── Rewarded Ad ──────────────────────────────────────────────────

  void loadRewardedAd() {
    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          _rewardedAd = null;
          debugPrint('RewardedAd failed to load: $error');
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

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onDone?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onDone?.call();
      },
    );

    await _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      onReward();
    });
  }
}