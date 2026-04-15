import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:kavachx/Controller/splash_controller.dart';
import 'package:get/get.dart';
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}