import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';

/// Singleton Ad Manager for Start.io SDK
class AdManager {
  AdManager._internal();
  static final AdManager instance = AdManager._internal();

  final StartAppSdk _sdk = StartAppSdk();

  StartAppBannerAd? bannerAd;
  StartAppInterstitialAd? interstitialAd;
  StartAppRewardedVideoAd? rewardedVideoAd;

  bool _initialized = false;
  bool _interstitialLoading = false;
  bool _rewardedLoading = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // TODO: Remove before production release
    _sdk.setTestAdsEnabled(true);

    _loadInterstitial();
    _loadRewarded();
  }

  // ─── Banner ────────────────────────────────────────────────────────────────

  Future<StartAppBannerAd?> loadBannerAd({String? adTag}) async {
    try {
      final ad = adTag != null
          ? await _sdk.loadBannerAd(
        StartAppBannerType.BANNER,
        prefs: StartAppAdPreferences(adTag: adTag),
      )
          : await _sdk.loadBannerAd(StartAppBannerType.BANNER);
      bannerAd = ad;
      return ad;
    } on StartAppException catch (ex) {
      debugPrint('Banner ad error: ${ex.message}');
    } catch (e) {
      debugPrint('Banner ad error: $e');
    }
    return null;
  }

  // ─── Interstitial ──────────────────────────────────────────────────────────

  void _loadInterstitial({String? adTag}) {
    if (_interstitialLoading) return;
    _interstitialLoading = true;

    final future = adTag != null
        ? _sdk.loadInterstitialAd(
      prefs: StartAppAdPreferences(adTag: adTag),
      onAdNotDisplayed: _onInterstitialDone,
      onAdHidden: _onInterstitialDone,
    )
        : _sdk.loadInterstitialAd(
      onAdNotDisplayed: _onInterstitialDone,
      onAdHidden: _onInterstitialDone,
    );

    future.then((ad) {
      debugPrint('✅ Interstitial loaded');
      interstitialAd = ad;
      _interstitialLoading = false;
    }).catchError((e) {
      debugPrint('❌ Interstitial load error: $e');
      interstitialAd = null;
      _interstitialLoading = false;
    });
  }

  void _onInterstitialDone() {
    interstitialAd?.dispose();
    interstitialAd = null;
    _interstitialLoading = false;
    _loadInterstitial(); // preload next one
  }

  /// Shows interstitial if ready, then navigates.
  /// Pass [onDone] — it will be called whether or not ad was shown.
  Future<void> showInterstitialAd({VoidCallback? onDone}) async {
    if (interstitialAd == null) {
      debugPrint('⚠️ Interstitial not ready, skipping');
      onDone?.call();
      return;
    }
    try {
      final shown = await interstitialAd!.show();
      debugPrint(shown ? '✅ Interstitial shown' : '⚠️ Interstitial not shown');
      if (shown) {
        interstitialAd = null;
        _interstitialLoading = false;
        _loadInterstitial();
      }
    } catch (e) {
      debugPrint('❌ Interstitial show error: $e');
    }
    onDone?.call();
  }

  // ─── Rewarded Video ────────────────────────────────────────────────────────

  void _loadRewarded({VoidCallback? onReward}) {
    if (_rewardedLoading) return;
    _rewardedLoading = true;

    _sdk.loadRewardedVideoAd(
      onAdNotDisplayed: () {
        debugPrint('⚠️ Rewarded not displayed');
        rewardedVideoAd?.dispose();
        rewardedVideoAd = null;
        _rewardedLoading = false;
      },
      onAdHidden: () {
        debugPrint('✅ Rewarded hidden');
        rewardedVideoAd?.dispose();
        rewardedVideoAd = null;
        _rewardedLoading = false;
        _loadRewarded(); // preload next
      },
      onVideoCompleted: () {
        debugPrint('🎉 Rewarded completed — grant reward');
        onReward?.call();
      },
    ).then((ad) {
      debugPrint('✅ Rewarded loaded');
      rewardedVideoAd = ad;
      _rewardedLoading = false;
    }).catchError((e) {
      debugPrint('❌ Rewarded load error: $e');
      rewardedVideoAd = null;
      _rewardedLoading = false;
    });
  }

  Future<void> showRewardedVideoAd({VoidCallback? onReward}) async {
    if (rewardedVideoAd == null) {
      debugPrint('⚠️ Rewarded not ready, loading now...');
      _loadRewarded(onReward: onReward);
      return;
    }
    try {
      await rewardedVideoAd!.show();
    } catch (e) {
      debugPrint('❌ Rewarded show error: $e');
    }
    _loadRewarded(onReward: onReward); // preload next
  }

  bool get isInterstitialReady => interstitialAd != null;
  bool get isRewardedReady => rewardedVideoAd != null;
}