import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

class SplashController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    if (_apiService.isLoggedIn()) {
      // Refresh fresh user data & gym association from server on launch
      try {
        final response = await _apiService.getMe();
        if (response.isOk && response.body != null) {
          _apiService.saveAuthPayload(response.body);
        }
      } catch (e) {
        debugPrint('[SplashController] Error syncing profile on splash: $e');
      }

      final userData = _apiService.getUserData();
      final String? role = userData?['role'];
      final bool isOnboarded = userData?['isOnboarded'] ?? false;

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
      Get.offAllNamed('/role-selection');
    }
  }
}
