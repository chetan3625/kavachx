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
    // Keep minimum splash display time (e.g. 2.5 seconds for brand visibility)
    await Future.delayed(const Duration(milliseconds: 2500));

    // Check if token exists in GetStorage
    if (_apiService.isLoggedIn()) {
      final userData = _apiService.getUserData();
      final String? role = userData?['role'];

      if (role == 'gym_owner') {
        // Navigate to Gym Owner Dashboard
        Get.offAllNamed('/owner-dashboard');
      } else if (role == 'gym_member') {
        // Navigate to Gym Member Dashboard
        Get.offAllNamed('/member-dashboard');
      } else {
        // Fallback to Role Selection if role is undefined
        Get.offAllNamed('/role-selection');
      }
    } else {
      // User is not logged in -> navigate to Role Selection
      Get.offAllNamed('/role-selection');
    }
  }
}