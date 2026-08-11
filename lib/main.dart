import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:get_x/get_navigation/src/root/get_material_app.dart';
import 'package:kavachx/VIew/splash.dart';
import 'package:kavachx/bindings/splashbinding.dart';


void main() {
  runApp(const KavachXApp());
}

class KavachXApp extends StatelessWidget {
  const KavachXApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KavachX',
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () =>  SplashView(),
          binding: SplashBinding(),
        ),
        // Add your other GetX routes here:
        // GetPage(name: '/login', page: () => const LoginView()),
        // GetPage(name: '/home', page: () => const HomeView()),
      ],
    );
  }
}