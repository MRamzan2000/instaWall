import 'package:InstaWall/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'custom_scroll_behavior.dart';

void main() {
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
          home: const SplashScreen(),
        );

      },
    );
  }
}
