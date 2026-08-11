import 'package:get_x/get_core/src/get_main.dart';
import 'package:get_x/get_navigation/src/extension_navigation.dart';
import 'package:get_x/get_state_manager/src/simple/get_controllers.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Simulate initial loading (e.g., checking backend auth token, local storage)
    await Future.delayed(const Duration(seconds: 3));

    // Logic placeholder: Check authentication state
    bool isLoggedIn = false; // Replace with actual storage check e.g., GetStorage().read('token')

    if (isLoggedIn) {
      // Replace with your Home/Dashboard route
      Get.offNamed('/home');
    } else {
      // Navigate to Login/Role Selection route
      Get.offNamed('/login');
    }
  }
}