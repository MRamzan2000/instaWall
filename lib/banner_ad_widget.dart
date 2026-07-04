import 'package:flutter/material.dart';
import 'meta_ad_manager.dart';

class BannerAdWidget extends StatefulWidget {
  final String? adTag;
  const BannerAdWidget({super.key, this.adTag});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        width: double.infinity,
        height: 50,
        color: Colors.transparent,
        child: MetaAdManager().buildBannerAd(adTag: widget.adTag),
      ),
    );
  }
}