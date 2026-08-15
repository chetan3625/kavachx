import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Constants/user_role.dart';
import 'package:kavachx/Model/usr_model.dart';
import 'package:kavachx/Services/api_service.dart';
import 'package:kavachx/Services/firebase_messaging_service.dart';
import 'package:kavachx/Services/socket_service.dart';

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
      _showSnackbar(
        'Error',
        'Please fill in required credentials',
        isError: true,
      );
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
        final Map<String, dynamic> body = Map<String, dynamic>.from(
          response.body,
        );

        // Safe extraction from root or nested 'data' key
        final Map<String, dynamic> data = body['data'] is Map
            ? Map<String, dynamic>.from(body['data'])
            : body;

        final String? token =
            body['accessToken'] ??
            body['token'] ??
            data['accessToken'] ??
            data['token'];

        final Map<String, dynamic>? userData = body['user'] is Map
            ? Map<String, dynamic>.from(body['user'])
            : (data['user'] is Map
                  ? Map<String, dynamic>.from(data['user'])
                  : null);

        if (token != null && token.isNotEmpty && userData != null) {
          final returnedRole = userData['role'];

          // Role Verification Check
          final String expectedRole = role == UserRole.gymOwner
              ? 'gym_owner'
              : 'gym_member';

          if (returnedRole != expectedRole) {
            final String correctPersona = returnedRole == 'gym_owner'
                ? 'Gym Owner'
                : 'Gym Member';

            _showSnackbar(
              'Access Denied',
              'This account is registered as a $correctPersona. Please switch to $correctPersona login.',
              isError: true,
            );
            return;
          }

          // Construct complete payload for ApiService local storage
          final Map<String, dynamic> payloadToSave = {
            'accessToken': token,
            'refreshToken': body['refreshToken'] ?? data['refreshToken'],
            'user': userData,
            'gym': body['gym'] ?? data['gym'],
            'qr': body['qr'] ?? data['qr'],
          };

          _apiService.saveAuthPayload(payloadToSave);

          if (Get.isRegistered<FirebaseMessagingService>()) {
            Get.find<FirebaseMessagingService>().syncToken();
          }

          if (Get.isRegistered<SocketService>()) {
            Get.find<SocketService>().joinUserRoom();
          }

          // Update current user state
          currentUser.value = UserModel.fromJson(userData);

          _showSnackbar(
            'Success',
            isRegister ? 'Registered successfully!' : 'Logged in successfully!',
          );

          // New member registrations complete preferences first; returning
          // member logins should land directly on the dashboard.
          if (currentUser.value?.role == 'gym_owner') {
            Get.offAllNamed('/owner-dashboard');
          } else if (!isRegister) {
            Get.offAllNamed('/member-dashboard');
          } else {
            if (currentUser.value?.isOnboarded == true) {
              Get.offAllNamed('/member-dashboard');
            } else {
              Get.offAllNamed('/member-onboarding');
            }
          }
        } else {
          _showSnackbar(
            'Error',
            'Invalid token or user data received',
            isError: true,
          );
        }
      } else {
        final errorMsg = response.body?['message'] ?? 'Authentication failed';
        _showSnackbar('Failed', errorMsg, isError: true);
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('[AUTH EXCEPTION] Error: $e');
      _showSnackbar(
        'Error',
        'Something went wrong. Check connection.',
        isError: true,
      );
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
