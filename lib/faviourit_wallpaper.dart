import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../ad_manager.dart';
import '../banner_ad_widget.dart';
import '../modal/modal.dart';
import '../preview_page.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Images> favorites;

  const FavoritesScreen({super.key, required this.favorites});

  void _openPreview(BuildContext context, Images wallpaper) {
    AdManager.instance.showInterstitialAd(
      onDone: () => Get.to(() => PreviewPage(
        imageId: wallpaper.imageID,
        imageUrl: wallpaper.imagePotraitPath,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E30),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 16),
          ),
        ),
      ),
      body: favorites.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border,
                color: Colors.white12, size: 8.h),
            SizedBox(height: 1.5.h),
            Text(
              'No favorites yet',
              style: TextStyle(
                  color: Colors.white38, fontSize: 15.sp),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Tap the ♡ on any wallpaper to save it here',
              style: TextStyle(
                  color: Colors.white24, fontSize: 12.sp),
            ),
          ],
        ),
      )
          : GridView.builder(
        padding: EdgeInsets.all(2.w),
        itemCount: favorites.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final wallpaper = favorites[index];
          return GestureDetector(
            onTap: () => _openPreview(context, wallpaper),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: wallpaper.imagePotraitPath,
                placeholder: (_, __) => Container(
                  color: const Color(0xFF1E1E30),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFF1E1E30),
                  child: const Icon(Icons.broken_image,
                      color: Colors.white30),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const BannerAdWidget(adTag: 'favorites_screen'),
    );
  }
}