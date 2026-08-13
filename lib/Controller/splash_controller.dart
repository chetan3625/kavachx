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
    await Future.delayed(const Duration(milliseconds: 2500));

    if (_apiService.isLoggedIn()) {
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