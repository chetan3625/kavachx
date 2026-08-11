import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kavachx/Constants/app_theme.dart';
import 'package:kavachx/Services/api_service.dart';
import 'package:kavachx/Services/token_refresh_service.dart';
import 'package:kavachx/VIew/splash.dart';
import 'package:kavachx/VIew/role_selection_screen.dart';
import 'package:kavachx/VIew/owner_dashboard_main)view.dart';
import 'package:kavachx/VIew/member_dashboard_view.dart';
import 'bindings/splashbinding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  Get.put(ApiService(), permanent: true);
await TokenRefreshService.initBackgroundRefresh();
  runApp(const KavachXApp());
}

class KavachXApp extends StatelessWidget {
  const KavachXApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KavachX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashView(),
          binding: SplashBinding(),
        ),
        GetPage(
          name: '/role-selection',
          page: () => const RoleSelectionView(),
        ),
        GetPage(
          name: '/owner-dashboard',
          page: () => const OwnerDashboardView(),
        ),
        GetPage(
          name: '/member-dashboard',
          page: () => const MemberDashboardView(),
        ),
      ],
    );
  }
}