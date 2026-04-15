import 'package:get/get.dart';
import 'package:kavachx/VIew/role_selection_screen.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.off(() => const RoleSelectionView());
  }
}