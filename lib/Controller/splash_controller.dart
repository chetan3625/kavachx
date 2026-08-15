import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/member_attendance_controller.dart';
import 'package:kavachx/Controller/member_dashboard_controller.dart';
import 'package:kavachx/Controller/member_subscription_controller.dart';
import 'package:kavachx/Controller/membership_plan_controller.dart';
import 'package:kavachx/Controller/owner_dashboard_controller.dart';
import 'package:kavachx/Controller/owner_members_controller.dart';
import 'package:kavachx/Controller/owner_profile_controller.dart';
import 'package:kavachx/Services/api_service.dart';
import 'package:kavachx/Services/firebase_messaging_service.dart';

class SplashController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    final Stopwatch stopwatch = Stopwatch()..start();

    if (_apiService.isLoggedIn()) {
      // Sync FCM token upon auto-login
      if (Get.isRegistered<FirebaseMessagingService>()) {
        Get.find<FirebaseMessagingService>().syncToken();
      }

      // Refresh fresh user data & gym association from server on launch
      try {
        var response = await _apiService.getMe();
        if (!response.isOk && response.statusCode == 401) {
          final refreshed = await _apiService.refreshAccessToken();
          if (refreshed) {
            response = await _apiService.getMe();
          }
        }
        if (response.isOk && response.body != null) {
          _apiService.saveAuthPayload(response.body);
        }
      } catch (e) {
        debugPrint('[SplashController] Error syncing profile on splash: $e');
      }

      final userData = _apiService.getUserData();
      final String? role = userData?['role'];
      final bool isOnboarded = userData?['isOnboarded'] ?? false;

      // Pre-warm and fetch all APIs while on splash screen for 60 FPS performance
      if (role != null) {
        await _preloadRoleData(role);
      }

      // Ensure minimum 1.5 second splash display for brand experience
      final int elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 1500) {
        await Future.delayed(Duration(milliseconds: 1500 - elapsed));
      }

      if (role == 'gym_owner') {
        Get.offAllNamed('/owner-dashboard');
      } else {
        if (!isOnboarded) {
          if (role == 'gym_member') {
            Get.offAllNamed('/member-onboarding');
          } else {
            Get.offAllNamed('/role-selection');
          }
        } else {
          if (role == 'gym_member') {
            Get.offAllNamed('/member-dashboard');
          } else {
            Get.offAllNamed('/role-selection');
          }
        }
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.offAllNamed('/role-selection');
    }
  }

  Future<void> _preloadRoleData(String role) async {
    try {
      if (role == 'gym_owner') {
        final ownerDashboard = Get.put(OwnerDashboardController());
        final ownerMembers = Get.put(OwnerMembersController());
        final planController = Get.put(MembershipPlanController());
        final ownerProfile = Get.put(OwnerProfileController());

        await Future.wait([
          ownerDashboard.fetchDashboardStats(),
          ownerMembers.fetchGymMembers(),
          planController.fetchPlans(),
          ownerProfile.fetchGymProfile(),
        ]);
      } else if (role == 'gym_member') {
        final memberDashboard = Get.put(MemberDashboardController());
        final memberAttendance = Get.put(MemberAttendanceController());
        final memberSubscription = Get.put(MemberSubscriptionController());

        await Future.wait([
          memberDashboard.fetchDashboardData(),
          memberAttendance.fetchAttendanceHistory(),
          memberSubscription.fetchSubscriptionDetails(),
        ]);
      }
    } catch (e) {
      debugPrint('[SplashController] Error preloading APIs on splash: $e');
    }
  }
}
