import 'package:InstaWall/splash_screen.dart';
import 'package:easy_audience_network_plus/easy_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'meta_ad_manager.dart';
import 'custom_scroll_behavior.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize with EasyAudienceNetwork
  EasyAudienceNetwork.init(
    // testingId: "9bfaea4f-d8ee-4e0c-a4b6-7c6f3952d348",
    testMode: false,  // ← false for real ads
    iOSAdvertiserTrackingEnabled: false,
  );

  // ✅ Initialize with testMode: false (Real ads)
  MetaAdManager().initialize(testMode: false);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: CustomScrollBehavior(),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A1A2E),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0F0F1A),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F0F1A),
              elevation: 0,
              centerTitle: true,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}