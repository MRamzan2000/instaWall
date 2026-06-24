import 'dart:async';
import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';


class AdManager {
  AdManager._internal();
  static final AdManager instance = AdManager._internal();

  final StartAppSdk _sdk = StartAppSdk();

  // ── Ad instances ──────────────────────────────────────────────────
  StartAppBannerAd? bannerAd;
  StartAppInterstitialAd? interstitialAd;
  StartAppInterstitialAd? videoInterstitialAd;
  StartAppRewardedVideoAd? rewardedVideoAd;
  StartAppNativeAd? nativeAd;

  // ── State guards ──────────────────────────────────────────────────
  bool _initialized = false;
  bool _interstitialLoading = false;
  bool _videoInterstitialLoading = false;
  bool _rewardedLoading = false;
  bool _nativeLoading = false;

  // ── Retry delays (back-off on no-fill) ───────────────────────────
  static const Duration _retryShort = Duration(seconds: 15);
  static const Duration _retryLong  = Duration(seconds: 30);

  /// Show an interstitial every N wallpaper taps
  static const int _interstitialFrequency = 3;
  int _tapsSinceLastInterstitial = 0;


  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _sdk.setTestAdsEnabled(false); // ✅ PRODUCTION

    // Stagger loads so they don't all hit the server at once
    _loadInterstitial();
    Future.delayed(const Duration(seconds: 5), _loadVideoInterstitial);
    Future.delayed(const Duration(seconds: 10), _loadRewarded);
    Future.delayed(const Duration(seconds: 15), _loadNativeAd);

    debugPrint('✅ AdManager initialized — production mode');
  }

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
      debugPrint('❌ Banner error: ${ex.message}');
    } catch (e) {
      debugPrint('❌ Banner error: $e');
    }
    return null;
  }


  void _loadInterstitial() {
    if (_interstitialLoading || interstitialAd != null) return;
    _interstitialLoading = true;

    _sdk.loadInterstitialAd(
      prefs: const StartAppAdPreferences(
        adTag: 'interstitial',
      ),
      onAdNotDisplayed: _onInterstitialDone,
      onAdHidden: _onInterstitialDone,
    ).then((ad) {
      debugPrint('✅ Interstitial loaded');
      interstitialAd = ad;
      _interstitialLoading = false;
    }).catchError((e) {
      debugPrint('❌ Interstitial error: $e — retrying in ${_retryShort.inSeconds}s');
      interstitialAd = null;
      _interstitialLoading = false;
      Future.delayed(_retryShort, _loadInterstitial);
    });
  }

  void _onInterstitialDone() {
    interstitialAd?.dispose();
    interstitialAd = null;
    _interstitialLoading = false;
    _loadInterstitial();
  }

  Future<void> showInterstitialAd({VoidCallback? onDone}) async {
    if (interstitialAd == null) {
      debugPrint('⚠️ Interstitial not ready');
      onDone?.call();
      return;
    }
    try {
      final shown = await interstitialAd!.show();
      debugPrint(shown ? '✅ Interstitial shown' : '⚠️ Interstitial skipped');
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

  /// Show interstitial only every N taps — avoids showing on every wallpaper open.
  Future<void> showInterstitialOnFrequency({VoidCallback? onDone}) async {
    _tapsSinceLastInterstitial++;
    if (_tapsSinceLastInterstitial >= _interstitialFrequency &&
        interstitialAd != null) {
      _tapsSinceLastInterstitial = 0;
      await showInterstitialAd(onDone: onDone);
    } else {
      onDone?.call();
    }
  }


  void _loadVideoInterstitial() {
    if (_videoInterstitialLoading || videoInterstitialAd != null) return;
    _videoInterstitialLoading = true;

    _sdk.loadInterstitialAd(
      prefs: const StartAppAdPreferences(
        adTag: 'video_interstitial',
        videoMuted: false, // prefer video creatives
      ),
      onAdNotDisplayed: _onVideoInterstitialDone,
      onAdHidden: _onVideoInterstitialDone,
    ).then((ad) {
      debugPrint('✅ Video Interstitial loaded');
      videoInterstitialAd = ad;
      _videoInterstitialLoading = false;
    }).catchError((e) {
      debugPrint('❌ Video Interstitial error: $e — retrying in ${_retryLong.inSeconds}s');
      videoInterstitialAd = null;
      _videoInterstitialLoading = false;
      Future.delayed(_retryLong, _loadVideoInterstitial);
    });
  }

  void _onVideoInterstitialDone() {
    videoInterstitialAd?.dispose();
    videoInterstitialAd = null;
    _videoInterstitialLoading = false;
    Future.delayed(_retryShort, _loadVideoInterstitial);
  }

  Future<void> showVideoInterstitialAd({VoidCallback? onDone}) async {
    // Fall back to regular interstitial if video not ready
    if (videoInterstitialAd == null) {
      debugPrint('⚠️ Video interstitial not ready — trying regular interstitial');
      if (interstitialAd != null) {
        await showInterstitialAd(onDone: onDone);
      } else {
        onDone?.call();
      }
      return;
    }
    try {
      final shown = await videoInterstitialAd!.show();
      debugPrint(shown ? '✅ Video Interstitial shown' : '⚠️ Video Interstitial skipped');
      if (shown) {
        videoInterstitialAd = null;
        _videoInterstitialLoading = false;
        Future.delayed(_retryShort, _loadVideoInterstitial);
      }
    } catch (e) {
      debugPrint('❌ Video Interstitial show error: $e');
    }
    onDone?.call();
  }


  void _loadRewarded({VoidCallback? onReward}) {
    if (_rewardedLoading || rewardedVideoAd != null) return;
    _rewardedLoading = true;

    _sdk.loadRewardedVideoAd(
      prefs: const StartAppAdPreferences(adTag: 'rewarded'),
      onAdNotDisplayed: () {
        debugPrint('⚠️ Rewarded not displayed');
        rewardedVideoAd?.dispose();
        rewardedVideoAd = null;
        _rewardedLoading = false;
        Future.delayed(_retryLong, _loadRewarded);
      },
      onAdHidden: () {
        debugPrint('✅ Rewarded hidden');
        rewardedVideoAd?.dispose();
        rewardedVideoAd = null;
        _rewardedLoading = false;
        _loadRewarded();
      },
      onVideoCompleted: () {
        debugPrint('🎉 Rewarded completed — granting reward');
        onReward?.call();
      },
    ).then((ad) {
      debugPrint('✅ Rewarded loaded');
      rewardedVideoAd = ad;
      _rewardedLoading = false;
    }).catchError((e) {
      debugPrint('❌ Rewarded error: $e — retrying in ${_retryLong.inSeconds}s');
      rewardedVideoAd = null;
      _rewardedLoading = false;
      Future.delayed(_retryLong, _loadRewarded);
    });
  }

  Future<void> showRewardedVideoAd({VoidCallback? onReward}) async {
    if (rewardedVideoAd == null) {
      debugPrint('⚠️ Rewarded not ready — loading now');
      _loadRewarded(onReward: onReward);
      return;
    }
    try {
      await rewardedVideoAd!.show();
    } catch (e) {
      debugPrint('❌ Rewarded show error: $e');
      onReward?.call(); // don't block the user if ad fails
    }
    _loadRewarded(onReward: onReward);
  }

  void _loadNativeAd() {
    if (_nativeLoading || nativeAd != null) return;
    _nativeLoading = true;

    _sdk.loadNativeAd(
      prefs: const StartAppAdPreferences(adTag: 'native_home'),
    ).then((ad) {
      debugPrint('✅ Native ad loaded');
      nativeAd = ad;
      _nativeLoading = false;
    }).catchError((e) {
      debugPrint('❌ Native ad error: $e — retrying in ${_retryLong.inSeconds}s');
      nativeAd = null;
      _nativeLoading = false;
      Future.delayed(_retryLong, _loadNativeAd);
    });
  }

  /// Call after a native ad is consumed to preload the next one.
  void refreshNativeAd({String? adTag}) {
    nativeAd = null;
    _nativeLoading = false;
    Future.delayed(_retryShort, _loadNativeAd);
  }


  bool get isInterstitialReady      => interstitialAd != null;
  bool get isVideoInterstitialReady => videoInterstitialAd != null;
  bool get isRewardedReady          => rewardedVideoAd != null;
  bool get isNativeReady            => nativeAd != null;
}