import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'Home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5)).then((value) => Get.off(()=>const HomeScreen()),);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: 10.h,
                  child: const Image(
                    image: AssetImage("assets/appicon.png"),
                    fit: BoxFit.cover,
                  )),
              SizedBox(height:1.h,),
              Text("wallpaper App",style: TextStyle(
                color: Colors.black.withOpacity(0.7),
                fontSize: 12.px,
                fontWeight: FontWeight.w800,
              ),)

            ],
          ),
        ),
      ),
    );
  }
}
