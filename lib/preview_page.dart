import 'package:InstaWall/repo/repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'ad_manager.dart';
import 'banner_ad_widget.dart';

class PreviewPage extends StatefulWidget {
  final String imageUrl;
  final int imageId;

  const PreviewPage({
    super.key,
    required this.imageId,
    required this.imageUrl,
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final Repository _repo = Repository();
  bool _isDownloading = false;

  Future<void> _download() async {
    setState(() => _isDownloading = true);
    await _repo.downloadImage(
      imageUrl: widget.imageUrl,
      imageId: widget.imageId,
      context: context,
    );
    setState(() => _isDownloading = false);
  }

  /// Show a rewarded video; download starts only after the video completes.
  void _downloadWithRewardedAd() {
    if (!AdManager.instance.isRewardedReady) {
      // No ad ready, download directly
      _download();
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Watch & Download',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Watch a short video to unlock the download.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              AdManager.instance.showRewardedVideoAd(onReward: _download);
            },
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),

      // Full-screen wallpaper
      body: SizedBox.expand(
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: widget.imageUrl,
          placeholder: (_, __) => const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          ),
          errorWidget: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image, color: Colors.white30)),
        ),
      ),

      // Bottom actions + banner
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Action bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.85),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Direct download
                _ActionButton(
                  icon: _isDownloading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.download_rounded,
                      color: Colors.white, size: 22),
                  label: 'Download',
                  color: const Color(0xFF6C63FF),
                  onTap: _isDownloading ? null : _download,
                ),

                // Rewarded ad download
                _ActionButton(
                  icon: const Icon(Icons.play_circle_outline,
                      color: Colors.white, size: 22),
                  label: 'Free Download',
                  color: const Color(0xFFFF6B6B),
                  onTap: _downloadWithRewardedAd,
                ),
              ],
            ),
          ),

          // Banner ad
          const BannerAdWidget(adTag: 'preview_screen'),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}