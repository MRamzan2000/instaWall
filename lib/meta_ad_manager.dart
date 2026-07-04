import 'package:easy_audience_network_plus/ad/banner_ad.dart';
import 'package:easy_audience_network_plus/ad/interstitial_ad.dart';
import 'package:easy_audience_network_plus/ad/rewarded_ad.dart';
import 'package:flutter/material.dart';

class MetaAdManager {
  static final MetaAdManager _instance = MetaAdManager._internal();
  factory MetaAdManager() => _instance;
  MetaAdManager._internal();

  bool _initialized = false;
  bool _useTestMode = false;

  // ── ✅ REAL PLACEMENT IDs (Dashboard se) ──────────────────────
  static const String BANNER_PLACEMENT_REAL =
      '1547222760352950_1547223710352855';  // Banner #1

  static const String INTERSTITIAL_PLACEMENT_REAL =
      '1547222760352950_1547223660352860';  // Interstitial #2

  static const String REWARDED_PLACEMENT_REAL =
      '1547222760352950_1547223670352859';  // Rewarded #6

  // ── TEST Placements (Only for testing) ──────────────────────────
  static const String BANNER_PLACEMENT_TEST =
      'IMG_16_9_APP_INSTALL#2312433698835503_2964943860251146';
  static const String INTERSTITIAL_PLACEMENT_TEST =
      'IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617';
  static const String REWARDED_PLACEMENT_TEST =
      'IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617';

  // ── Get current placements ──────────────────────────────────────
  String get _bannerPlacement => _useTestMode
      ? BANNER_PLACEMENT_TEST
      : BANNER_PLACEMENT_REAL;

  String get _interstitialPlacement => _useTestMode
      ? INTERSTITIAL_PLACEMENT_TEST
      : INTERSTITIAL_PLACEMENT_REAL;

  String get _rewardedPlacement => _useTestMode
      ? REWARDED_PLACEMENT_TEST
      : REWARDED_PLACEMENT_REAL;

  // ── Ad state ──────────────────────────────────────────────────────
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;

  // ── Ad instances ──────────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // ── Callbacks ─────────────────────────────────────────────────────
  VoidCallback? _pendingRewardCallback;
  VoidCallback? _pendingDoneCallback;

  // ── Initialization ───────────────────────────────────────────────

  Future<void> initialize({bool testMode = false}) async {
    if (_initialized) return;
    _useTestMode = testMode;
    _initialized = true;

    debugPrint('✅ Meta Ad Manager initialized (Test Mode: $_useTestMode)');
    debugPrint('📱 Banner: $_bannerPlacement');
    debugPrint('📱 Interstitial: $_interstitialPlacement');
    debugPrint('📱 Rewarded: $_rewardedPlacement');

    _loadInterstitial();
    _loadRewardedVideo();
  }

  // ── Getters ──────────────────────────────────────────────────────

  bool get isInterstitialReady => _isInterstitialLoaded;
  bool get isRewardedReady => _isRewardedLoaded;

  // ── Banner Ad ────────────────────────────────────────────────────

  Widget buildBannerAd({String? adTag}) {
    return BannerAd(
      placementId: _bannerPlacement,
      bannerSize: BannerSize.STANDARD,
      listener: BannerAdListener(
        onError: (code, message) {
          debugPrint('❌ Banner error: $code - $message');
        },
        onLoaded: () {
          debugPrint('✅ Banner loaded');
        },
        onClicked: () {
          debugPrint('👆 Banner clicked');
        },
        onLoggingImpression: () {
          debugPrint('👁️ Banner impression');
        },
      ),
    );
  }

  // ── Interstitial Ad ─────────────────────────────────────────────

  void _loadInterstitial() {
    // Dispose old ad if exists
    _interstitialAd?.destroy();
    _interstitialAd = null;
    _isInterstitialLoaded = false;

    _interstitialAd = InterstitialAd(_interstitialPlacement);
    _interstitialAd!.listener = InterstitialAdListener(
      onLoaded: () {
        _isInterstitialLoaded = true;
        debugPrint('✅ Interstitial loaded');
      },
      onError: (code, message) {
        _isInterstitialLoaded = false;
        debugPrint('❌ Interstitial error: $code - $message');
        Future.delayed(const Duration(seconds: 10), _loadInterstitial);
      },
      onDismissed: () {
        _isInterstitialLoaded = false;
        debugPrint('❌ Interstitial dismissed');
        _interstitialAd?.destroy();
        _interstitialAd = null;
        Future.delayed(const Duration(milliseconds: 500), _loadInterstitial);
      },
      onClicked: () {
        debugPrint('👆 Interstitial clicked');
      },
      onLoggingImpression: () {
        debugPrint('👁️ Interstitial impression');
      },
    );

    _interstitialAd!.load();
  }

  Future<bool> showInterstitial({VoidCallback? onDone}) async {
    if (!_isInterstitialLoaded || _interstitialAd == null) {
      debugPrint('⚠️ Interstitial not ready');
      onDone?.call();
      return false;
    }

    try {
      _interstitialAd!.show();
      _isInterstitialLoaded = false;
      debugPrint('✅ Interstitial shown');
      onDone?.call();
      return true;
    } catch (e) {
      debugPrint('❌ Interstitial show error: $e');
      onDone?.call();
      return false;
    }
  }

  // ── Rewarded Video Ad ────────────────────────────────────────────

  void _loadRewardedVideo() {
    // Dispose old ad if exists
    _rewardedAd?.destroy();
    _rewardedAd = null;
    _isRewardedLoaded = false;

    _rewardedAd = RewardedAd(
      _rewardedPlacement,
      userId: '', // optional for server side verification
    );

    _rewardedAd!.listener = RewardedAdListener(
      onLoaded: () {
        _isRewardedLoaded = true;
        debugPrint('✅ Rewarded ad loaded');
      },
      onError: (code, message) {
        _isRewardedLoaded = false;
        debugPrint('❌ Rewarded error: $code - $message');
        Future.delayed(const Duration(seconds: 15), _loadRewardedVideo);
      },
      onVideoComplete: () {
        debugPrint('🎉 Rewarded video completed');
        _handleRewardComplete();
      },

      onClicked: () {
        debugPrint('👆 Rewarded ad clicked');
      },
      onLoggingImpression: () {
        debugPrint('👁️ Rewarded impression');
      },
    );

    _rewardedAd!.load();
  }

  Future<void> showRewardedVideo({
    VoidCallback? onReward,
    VoidCallback? onDone,
  }) async {
    if (!_isRewardedLoaded || _rewardedAd == null) {
      debugPrint('⚠️ Rewarded ad not ready - showing Interstitial instead');
      await showInterstitial(onDone: onDone);
      return;
    }

    try {
      _pendingRewardCallback = onReward;
      _pendingDoneCallback = onDone;
      _rewardedAd!.show();
      debugPrint('✅ Rewarded video shown');
    } catch (e) {
      debugPrint('❌ Rewarded show error: $e');
      await showInterstitial(onDone: onDone);
    }
  }

  void _handleRewardComplete() {
    // Reward callback is called when video completes
    if (_pendingRewardCallback != null) {
      _pendingRewardCallback!();
      _pendingRewardCallback = null;
    }
    if (_pendingDoneCallback != null) {
      _pendingDoneCallback!();
      _pendingDoneCallback = null;
    }
  }

  // ── Cleanup ──────────────────────────────────────────────────────

  void dispose() {
    _interstitialAd?.destroy();
    _rewardedAd?.destroy();
    _interstitialAd = null;
    _rewardedAd = null;
  }
}