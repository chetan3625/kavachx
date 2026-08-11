import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Constants/user_role.dart';
import 'package:kavachx/Model/usr_model.dart';
import 'package:kavachx/Services/api_service.dart';

class AuthController extends GetxController {
  final UserRole role;
  AuthController({required this.role});

  final ApiService _apiService = Get.find<ApiService>();

  final RxInt selectedTab = 0.obs; // 0 = Login, 1 = Register
  final RxBool isLoading = false.obs;

  // Text Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // Gym Owner Specific Controllers
  final gymNameController = TextEditingController();
  final gymPhoneController = TextEditingController();
  final gymAddressController = TextEditingController();

  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  void submitAuth() async {
    final isRegister = selectedTab.value == 1;

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showSnackbar('Error', 'Please fill in required credentials', isError: true);
      return;
    }

    isLoading.value = true;

    try {
      Response response;

      if (isRegister) {
        if (role == UserRole.gymOwner) {
          response = await _apiService.registerOwner(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            password: passwordController.text.trim(),
            gymName: gymNameController.text.trim(),
            gymPhone: gymPhoneController.text.trim(),
            gymAddress: gymAddressController.text.trim(),
          );
        } else {
          response = await _apiService.registerMember(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            phone: phoneController.text.trim(),
            password: passwordController.text.trim(),
          );
        }
      } else {
        response = await _apiService.login(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }

      isLoading.value = false;

      if (response.isOk && response.body != null) {
        final data = response.body;
        
        if (data['accessToken'] != null) {
          _apiService.accessToken = data['accessToken'];
        }

        if (data['user'] != null) {
          currentUser.value = UserModel.fromJson(data['user']);
        }

        _showSnackbar(
          'Success',
          isRegister ? 'Registered successfully!' : 'Logged in successfully!',
        );

        // TODO: Redirect to Dashboard based on role
        // if (role == UserRole.gymOwner) Get.offAllNamed('/owner-dashboard');
      } else {
        final errorMsg = response.body?['message'] ?? 'Authentication failed';
        _showSnackbar('Failed', errorMsg, isError: true);
      }
    } catch (e) {
      isLoading.value = false;
      _showSnackbar('Error', 'Something went wrong. Check connection.', isError: true);
    }
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1C1C22),
      colorText: Colors.white,
      borderColor: isError ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
      borderWidth: 1,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    gymNameController.dispose();
    gymPhoneController.dispose();
    gymAddressController.dispose();
    super.onClose();
  }
}