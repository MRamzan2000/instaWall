import 'dart:async';
import 'package:flutter/material.dart';
import 'meta_ad_manager.dart';

/// Combined Ad Manager - uses Meta Audience Network
class AdManager {
  AdManager._internal();
  static final AdManager instance = AdManager._internal();

  final MetaAdManager _meta = MetaAdManager();

  /// Show interstitial every N wallpaper taps
  static const int _interstitialFrequency = 3;
  int _tapsSinceLastInterstitial = 0;

  // ── Getters ──────────────────────────────────────────────────────

  bool get isRewardedReady => _meta.isRewardedReady;

  // ── Interstitial ──────────────────────────────────────────────────

  Future<void> showInterstitialOnFrequency({VoidCallback? onDone}) async {
    _tapsSinceLastInterstitial++;
    if (_tapsSinceLastInterstitial >= _interstitialFrequency &&
        _meta.isInterstitialReady) {
      _tapsSinceLastInterstitial = 0;
      await _meta.showInterstitial(onDone: onDone);
    } else {
      onDone?.call();
    }
  }

  Future<void> showInterstitialAd({VoidCallback? onDone}) async {
    await _meta.showInterstitial(onDone: onDone);
  }

  Future<void> showVideoInterstitialAd({VoidCallback? onDone}) async {
    await _meta.showInterstitial(onDone: onDone);
  }

  // ── Rewarded Video ───────────────────────────────────────────────

  Future<void> showRewardedVideoAd({
    VoidCallback? onReward,
    VoidCallback? onDone,
  }) async {
    await _meta.showRewardedVideo(
      onReward: onReward,
      onDone: onDone,
    );
  }
}