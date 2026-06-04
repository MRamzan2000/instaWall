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
  List<Images> _favorites = [];

  bool _isSearching = false;
  String _searchQuery = '';

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

  // ── Favorites ──────────────────────────────────────────────────────────────

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

  // ── Search ─────────────────────────────────────────────────────────────────

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.trim();
      if (_searchQuery.isEmpty) {
        _imagesFuture = _repo.getImagesList(pageNumber: 1);
      } else {
        _imagesFuture = _repo.getImagesBySearch(query: _searchQuery);
      }
    });
  }

  // ── Navigation with interstitial ───────────────────────────────────────────

  void _navigateToPreview(Images wallpaper) {
    AdManager.instance.showInterstitialAd(
      onDone: () => Get.to(() => PreviewPage(
        imageId: wallpaper.imageID,
        imageUrl: wallpaper.imagePotraitPath,
      )),
    );
  }

  void _navigateToFavorites() {
    AdManager.instance.showInterstitialAd(
      onDone: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FavoritesScreen(favorites: _favorites),
        ),
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          // Grid
          Expanded(child: _buildGrid()),
        ],
      ),
      // Banner ad pinned at the bottom
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
        // Search toggle
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
        // Favorites
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: 0.5.w),
      ],
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
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14.sp,
                ),
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
                Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.white38, fontSize: 14.sp),
                ),
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
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: wallpaper.imagePotraitPath,
                      placeholder: (_, __) => Container(
                        height: 20.h,
                        color: const Color(0xFF1E1E30),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 20.h,
                        color: const Color(0xFF1E1E30),
                        child: const Icon(Icons.broken_image,
                            color: Colors.white30),
                      ),
                    ),
                  ),

                  // Gradient overlay
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

                  // Favorite button
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