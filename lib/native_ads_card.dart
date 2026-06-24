import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:startapp_sdk/startapp.dart';
import 'ad_manager.dart';

/// Native ad card — inject into the wallpaper grid every N items.
class NativeAdCard extends StatefulWidget {
  final String? adTag;
  const NativeAdCard({super.key, this.adTag});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  StartAppNativeAd? _nativeAd;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (AdManager.instance.isNativeReady) {
      if (mounted) {
        setState(() {
          _nativeAd = AdManager.instance.nativeAd;
          _loading = false;
        });
        AdManager.instance.refreshNativeAd(adTag: widget.adTag);
      }
      return;
    }

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      if (AdManager.instance.isNativeReady) {
        setState(() {
          _nativeAd = AdManager.instance.nativeAd;
          _loading = false;
        });
        AdManager.instance.refreshNativeAd(adTag: widget.adTag);
        return;
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  Widget _buildAdContent(StartAppNativeAd ad) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ad.imageUrl != null)
            SizedBox(
              height: 12.h,
              width: double.infinity,
              child: Image.network(
                ad.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF0F0F1A)),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Sponsored',
                    style: TextStyle(
                      color: const Color(0xFF6C63FF),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 0.5.h),
                if (ad.title != null)
                  Text(
                    ad.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (ad.description != null)
                  Text(
                    ad.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10.sp,
                    ),
                  ),
                SizedBox(height: 0.8.h),
                if (ad.callToAction != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: EdgeInsets.symmetric(vertical: 0.8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        ad.callToAction!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 20.h,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E30),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF6C63FF),
            ),
          ),
        ),
      );
    }

    if (_nativeAd == null) return const SizedBox.shrink();

    // StartAppNativeWidgetBuilder = (BuildContext, StateSetter, StartAppNativeAd) → Widget
    return StartAppNative(
      _nativeAd!,
          (BuildContext ctx, StateSetter setAdState, StartAppNativeAd ad) =>
          _buildAdContent(ad),
    );
  }
}