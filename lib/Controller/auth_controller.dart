import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
        final body = response.body;
        // Safely extract data block whether it's wrapped in 'data' or top-level
        final Map<String, dynamic> data = body['data'] ?? body;
        final String? token = data['accessToken'];
        final Map<String, dynamic>? userData = data['user'];

        if (token != null && userData != null) {
          final returnedRole = userData['role'];

          // Role Verification Check
          final String expectedRole =
              role == UserRole.gymOwner ? 'gym_owner' : 'gym_member';

          if (returnedRole != expectedRole) {
            final String correctPersona =
                returnedRole == 'gym_owner' ? 'Gym Owner' : 'Gym Member';

            _showSnackbar(
              'Access Denied',
              'This account is registered as a $correctPersona. Please switch to $correctPersona login.',
              isError: true,
            );
            return;
          }

          // Save accessToken, refreshToken, user, and qr details centrally
          _apiService.saveAuthPayload(data);
          
          // Update current user state
          currentUser.value = UserModel.fromJson(userData);

          _showSnackbar(
            'Success',
            isRegister ? 'Registered successfully!' : 'Logged in successfully!',
          );

          // Route to appropriate dashboard
          if (currentUser.value?.role == 'gym_owner') {
            Get.offAllNamed('/owner-dashboard');
          } else {
            Get.offAllNamed('/member-dashboard');
          }
        } else {
          _showSnackbar('Error', 'Invalid token or user data received', isError: true);
        }
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