import 'package:flutter/material.dart';
import 'package:startapp_sdk/startapp.dart';
import 'ad_manager.dart';

/// Drop this widget into the bottomNavigationBar slot (or bottom of a Column)
/// on every screen to show a self-refreshing banner ad.
///
/// Usage:
///   bottomNavigationBar: const BannerAdWidget(),
class BannerAdWidget extends StatefulWidget {
  final String? adTag;
  const BannerAdWidget({super.key, this.adTag});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  StartAppBannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    final ad = await AdManager.instance.loadBannerAd(adTag: widget.adTag);
    if (mounted) {
      setState(() => _bannerAd = ad);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null) {
      // Reserve space so the layout doesn't jump when the ad loads
      return const SizedBox(height: 50);
    }
    return SizedBox(
      height: 50,
      child: StartAppBanner(_bannerAd!),
    );
  }
}