import 'dart:async';
import 'package:flutter/material.dart';
import 'ad_mob_service.dart';

/// Professional Ad Manager - Bridges to AdMobService
class AdManager {
  AdManager._internal();
  static final AdManager instance = AdManager._internal();

  /// Show interstitial every N wallpaper taps
  static const int _interstitialFrequency = 3;
  int _tapsSinceLastInterstitial = 0;

  DateTime? _lastAdTime;
  static const Duration _cooldown = Duration(minutes: 1);

  // ── Getters ──────────────────────────────────────────────────────

  bool get isRewardedReady => AdMobService.instance.isRewardedReady;

  // ── Interstitial ──────────────────────────────────────────────────

  Future<void> showInterstitialOnFrequency({VoidCallback? onDone}) async {
    _tapsSinceLastInterstitial++;
    
    // Check frequency and cooldown to avoid overloading user
    bool canShow = _tapsSinceLastInterstitial >= _interstitialFrequency;
    bool cooledDown = _lastAdTime == null || 
        DateTime.now().difference(_lastAdTime!) > _cooldown;

    if (canShow && cooledDown) {
      _tapsSinceLastInterstitial = 0;
      _lastAdTime = DateTime.now();
      await AdMobService.instance.showInterstitialAd(onDone: onDone);
    } else {
      onDone?.call();
    }
  }

  Future<void> showInterstitialAd({VoidCallback? onDone}) async {
    await AdMobService.instance.showInterstitialAd(onDone: onDone);
    _lastAdTime = DateTime.now();
  }

  /// Compatibility for legacy code
  Future<void> showVideoInterstitialAd({VoidCallback? onDone}) async {
    await showInterstitialAd(onDone: onDone);
  }

  // ── Rewarded Video ───────────────────────────────────────────────

  Future<void> showRewardedVideoAd({
    required VoidCallback onReward,
    VoidCallback? onDone,
  }) async {
    await AdMobService.instance.showRewardedAd(
      onReward: onReward,
      onDone: onDone,
    );
  }
}