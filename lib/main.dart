import 'package:InstaWall/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'ad_mob_service.dart';
import 'custom_scroll_behavior.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize AdMob
  await AdMobService.instance.init();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ Handle App Open Ad on Resume
    if (state == AppLifecycleState.resumed) {
      AdMobService.instance.showAppOpenAdIfAvailable();
    }
  }

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