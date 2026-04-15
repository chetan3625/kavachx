import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Constants/user_role.dart';

class AuthController extends GetxController {
  final UserRole role;
  AuthController({required this.role});

  // Reactive state for tab toggle (0 = Login, 1 = Register)
  final RxInt selectedTab = 0.obs;

  // Text Controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  void submitAuth() {
    final mode = selectedTab.value == 0 ? 'Login' : 'Register';
    
    // Prints the selected role directly
    debugPrint('User is ${role.name} ($mode)');
    
    Get.snackbar(
      'Auth Action',
      'User is ${role.name} ($mode)',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1C1C22),
      colorText: Colors.white,
      borderColor: const Color(0xFFFF3B30),
      borderWidth: 1,
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }
}