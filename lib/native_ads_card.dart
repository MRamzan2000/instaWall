import 'package:flutter/material.dart';

/// Native ad card - DISABLED as requested
class NativeAdCard extends StatelessWidget {
  final String? adTag;
  const NativeAdCard({super.key, this.adTag});

  @override
  Widget build(BuildContext context) {
    // Return empty container - no native ads
    return const SizedBox.shrink();
  }
}