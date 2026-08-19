import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kavachx/Constants/app_theme.dart';
import 'package:kavachx/Constants/app_transitions.dart';
import 'package:kavachx/Services/api_service.dart';
import 'package:kavachx/Services/token_refresh_service.dart';
import 'package:kavachx/VIew/splash.dart';
import 'package:kavachx/VIew/role_selection_screen.dart';
import 'package:kavachx/VIew/owner_dashboard_main_view.dart';
import 'package:kavachx/VIew/member_dashboard_view.dart';
import 'package:kavachx/Services/socket_service.dart';
import 'bindings/splashbinding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kavachx/Services/firebase_messaging_service.dart';
import 'package:kavachx/VIew/member_onboarding_view.dart';
import 'package:kavachx/VIew/owner_onboarding_view.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('[Firebase] Init error: $e');
  }

  Get.put(ApiService(), permanent: true);
  Get.put(SocketService(), permanent: true);
  await TokenRefreshService.initBackgroundRefresh();

  // Initialize FCM
  try {
    await Get.putAsync(() => FirebaseMessagingService().init(), permanent: true);
  } catch (e) {
    debugPrint('[FCM] Service init error: $e');
  }

  runApp(const KavachXApp());
}

class KavachXApp extends StatelessWidget {
  const KavachXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KavachX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      // Default page transition — smooth right-to-left slide with fade for all screens
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 320),
      initialRoute: '/splash',
      getPages: [
        // Splash — no animation (app start)
        GetPage(
          name: '/splash',
          page: () => const SplashView(),
          binding: SplashBinding(),
          transition: Transition.noTransition,
        ),
        // Role Selection — elegant hero fade (brand reveal)
        GetPage(
          name: '/role-selection',
          page: () => const RoleSelectionView(),
          transition: AppTransitions.heroFadeTransition,
          transitionDuration: AppTransitions.heroFadeDuration,
          curve: Curves.easeInOutCubic,
        ),
        // Owner Dashboard — fade + slide (auth → main experience)
        GetPage(
          name: '/owner-dashboard',
          page: () => const OwnerDashboardMainView(),
          transition: AppTransitions.fadeSlideTransition,
          transitionDuration: AppTransitions.dashboardDuration,
          curve: Curves.easeOutCubic,
        ),
        // Member Dashboard — fade + slide (auth → main experience)
        GetPage(
          name: '/member-dashboard',
          page: () => const MemberDashboardView(),
          transition: AppTransitions.fadeSlideTransition,
          transitionDuration: AppTransitions.dashboardDuration,
          curve: Curves.easeOutCubic,
        ),
        // Member Onboarding — slide up (sheet-like onboarding feel)
        GetPage(
          name: '/member-onboarding',
          page: () => const MemberOnboardingView(),
          transition: AppTransitions.slideUpTransition,
          transitionDuration: AppTransitions.onboardingDuration,
          curve: Curves.easeOutCubic,
        ),
        // Owner Onboarding — slide up (sheet-like onboarding feel)
        GetPage(
          name: '/owner-onboarding',
          page: () => const OwnerMembersView(),
          transition: AppTransitions.slideUpTransition,
          transitionDuration: AppTransitions.onboardingDuration,
          curve: Curves.easeOutCubic,
        ),
      ],
    );
  }
}