import 'package:InstaWall/preview_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'ad_manager.dart';
import 'banner_ad_widget.dart';
import 'faviourit_wallpaper.dart';
import 'modal/modal.dart';
import 'repo/repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Repository _repo = Repository();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Images>> _imagesFuture;
  final List<Images> _favorites = [];

  bool _isSearching = false;
  String _searchQuery = '';
  bool _isBonusClaiming = false;

  @override
  void initState() {
    super.initState();
    _imagesFuture = _repo.getImagesList(pageNumber: 1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Favorites ─────────────────────────────────────────────────────

  void _toggleFavorite(Images wallpaper) {
    setState(() {
      if (_favorites.contains(wallpaper)) {
        _favorites.remove(wallpaper);
        _showSnack('Removed from Favorites', Icons.heart_broken_outlined);
      } else {
        _favorites.add(wallpaper);
        _showSnack('Added to Favorites', Icons.favorite);
      }
    });
  }

  void _showSnack(String msg, IconData icon) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E1E30),
        content: Row(
          children: [
            Icon(icon, color: const Color(0xFF6C63FF), size: 18),
            const SizedBox(width: 8),
            Text(msg, style: const TextStyle(color: Colors.white)),
          ],
        ),
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Search ────────────────────────────────────────────────────────

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.trim();
      _imagesFuture = _searchQuery.isEmpty
          ? _repo.getImagesList(pageNumber: 1)
          : _repo.getImagesBySearch(query: _searchQuery);
    });
  }

  // ── Navigation ────────────────────────────────────────────────────

  void _navigateToPreview(Images wallpaper) {
    AdManager.instance.showInterstitialOnFrequency(
      onDone: () => Get.to(() => PreviewPage(
        imageId: wallpaper.imageID,
        imageUrl: wallpaper.imagePotraitPath,
      )),
    );
  }

  void _navigateToFavorites() {
    AdManager.instance.showVideoInterstitialAd(
      onDone: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FavoritesScreen(favorites: _favorites),
        ),
      ),
    );
  }

  // ── Claim Bonus (Rewarded Video) ──────────────────────────────────

  void _claimBonusWallpaper() {
    if (!AdManager.instance.isRewardedReady) {
      // Show interstitial instead of claiming bonus
      _showSnack('🎬 Loading ad...', Icons.hourglass_top);
      AdManager.instance.showInterstitialAd(
        onDone: () {
          _showSnack('Enjoy your bonus wallpaper!', Icons.check_circle);
          _refreshWallpapers();
        },
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            SizedBox(width: 10),
            Text(
              'Claim Bonus 4K',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.video_library_rounded,
                      color: const Color(0xFF6C63FF), size: 8.h),
                  SizedBox(height: 1.h),
                  Text(
                    'Watch a short ad',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'to unlock a FREE 4K wallpaper!',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 4.w),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Watch the full ad to claim your reward',
                      style: TextStyle(color: Colors.amber, fontSize: 11.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            ),
            onPressed: () {
              Navigator.pop(context);
              _startBonusAd();
            },
            child: const Text('Watch Ad',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _startBonusAd() {
    setState(() => _isBonusClaiming = true);
    _showSnack('🎬 Loading ad...', Icons.hourglass_top);

    AdManager.instance.showRewardedVideoAd(
      onReward: () {
        setState(() => _isBonusClaiming = false);
        _showBonusSuccessDialog();
        _refreshWallpapers();
      },
      onDone: () {
        if (mounted) {
          setState(() => _isBonusClaiming = false);
        }
      },
    );

    // Safety timeout
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isBonusClaiming) {
        setState(() => _isBonusClaiming = false);
      }
    });
  }

  void _showBonusSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.green, size: 32),
            SizedBox(width: 10),
            Text(
              '🎉 Bonus Unlocked!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFF6C63FF).withOpacity(0.2),
                  Colors.purple.withOpacity(0.1),
                ]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.wallpaper_rounded,
                      color: const Color(0xFF6C63FF), size: 10.h),
                  SizedBox(height: 1.h),
                  Text(
                    '4K Wallpaper Added!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Check your feed for new premium wallpapers',
                    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _refreshWallpapers() {
    setState(() {
      _imagesFuture = _repo.getImagesList(pageNumber: 1);
    });
    _showSnack('🔄 New wallpapers loaded!', Icons.refresh);
  }

  // ── UI ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          _buildClaimBonusButton(),
          const SizedBox(height: 10),
          Expanded(child: _buildGrid()),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(adTag: 'home_screen'),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F0F1A),
      elevation: 0,
      title: _isSearching
          ? TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search wallpapers...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          border: InputBorder.none,
        ),
        onSubmitted: _onSearch,
      )
          : SizedBox(
        height: 4.h,
        child: const Image(
          image: AssetImage('assets/appicon.png'),
          fit: BoxFit.contain,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _onSearch('');
              }
            });
          },
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.favorite, color: Colors.deepOrange, size: 3.h),
              onPressed: _navigateToFavorites,
            ),
            if (_favorites.isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${_favorites.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: 0.5.w),
      ],
    );
  }

  Widget _buildClaimBonusButton() {
    return GestureDetector(
      onTap: _isBonusClaiming ? null : _claimBonusWallpaper,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF6C63FF), Colors.purple.shade700],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isBonusClaiming)
              SizedBox(
                width: 3.w,
                height: 3.w,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            else
              const Icon(Icons.emoji_events_rounded,
                  color: Colors.amber, size: 28),
            SizedBox(width: 2.w),
            Text(
              _isBonusClaiming ? 'Loading...' : 'Claim Bonus',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600),
            ),
            if (!_isBonusClaiming) ...[
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '4K FREE',
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    if (_isSearching) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      child: GestureDetector(
        onTap: () => setState(() => _isSearching = true),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E30),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.white38, size: 2.2.h),
              SizedBox(width: 2.w),
              Text(
                'Search wallpapers...',
                style: TextStyle(color: Colors.white38, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return FutureBuilder<List<Images>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, color: Colors.white30, size: 6.h),
                SizedBox(height: 1.h),
                Text('Something went wrong',
                    style: TextStyle(color: Colors.white38, fontSize: 14.sp)),
              ],
            ),
          );
        }

        final images = snapshot.data!;

        return MasonryGridView.count(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: images.length,
          itemBuilder: (context, index) {
            final wallpaper = images[index];
            final isFav = _favorites.contains(wallpaper);

            return GestureDetector(
              onTap: () => _navigateToPreview(wallpaper),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: wallpaper.imagePotraitPath,
                      placeholder: (_, __) => Container(
                          height: 20.h, color: const Color(0xFF1E1E30)),
                      errorWidget: (_, __, ___) => Container(
                        height: 20.h,
                        color: const Color(0xFF1E1E30),
                        child: const Icon(Icons.broken_image,
                            color: Colors.white30),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(14)),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(wallpaper),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.redAccent : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}