import 'package:InstaWall/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'ad_manager.dart';
import 'custom_scroll_behavior.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Start.io ad manager once at app startup
  AdManager.instance.initialize();
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