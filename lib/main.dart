import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Constants/app_theme.dart';
import 'package:kavachx/Services/api_service.dart';
import 'package:kavachx/VIew/splash.dart';
import 'bindings/splashbinding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inject ApiService globally before running the app
  Get.put(ApiService(), permanent: true);

  runApp(const KavachXApp());
}

class KavachXApp extends StatelessWidget {
  const KavachXApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KavachX',
      debugShowCheckedModeBanner: false,
      
      // Apply the Dark Theme
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashView(),
          binding: SplashBinding(),
        ),
      ],
    );
  }
}