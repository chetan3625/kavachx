import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/owner_dashboard_controller.dart';
import 'package:kavachx/Services/api_service.dart';

class OwnerProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  // Owner & Gym Data Maps
  final RxMap<String, dynamic> ownerData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> gymData = <String, dynamic>{}.obs;

  // Editable Form Controllers
  final ownerNameController = TextEditingController();
  final phoneController = TextEditingController();
  final gymNameController = TextEditingController();
  final gymPhoneController = TextEditingController();
  final gymAddressController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadFromLocalCache();
    fetchGymProfile();
  }

  void _loadFromLocalCache() {
    final userData = _apiService.getUserData();
    if (userData != null && userData.isNotEmpty) {
      ownerData.value = Map<String, dynamic>.from(userData);
      ownerNameController.text = userData['name'] ?? '';
      phoneController.text = userData['phone'] ?? '';
    }

    if (Get.isRegistered<OwnerDashboardController>()) {
      final dashboard = Get.find<OwnerDashboardController>();
      if (ownerNameController.text.isEmpty) {
        ownerNameController.text = dashboard.ownerName.value;
      }
      gymNameController.text = dashboard.gymName.value;
      gymPhoneController.text = dashboard.gymPhone.value;
      gymAddressController.text = dashboard.gymAddress.value;
      gymData['gymToken'] = dashboard.gymToken.value;
      gymData['name'] = dashboard.gymName.value;
      gymData['phone'] = dashboard.gymPhone.value;
      gymData['address'] = dashboard.gymAddress.value;
    }

    if (ownerNameController.text.isNotEmpty || gymNameController.text.isNotEmpty) {
      isLoading.value = false;
    }
  }

  Future<void> fetchGymProfile() async {
    try {
      final response = await _apiService.getGymProfile();
      if (response.isOk && response.body?['success'] == true) {
        final data = response.body['data'] ?? {};
        ownerData.value = Map<String, dynamic>.from(data['owner'] ?? {});
        gymData.value = Map<String, dynamic>.from(data['gym'] ?? {});

        ownerNameController.text = ownerData['name'] ?? '';
        phoneController.text = ownerData['phone'] ?? '';
        gymNameController.text = gymData['name'] ?? '';
        gymPhoneController.text = gymData['phone'] ?? '';
        gymAddressController.text = gymData['address'] ?? '';
      } else {
        // Fallback to /auth/me
        final userRes = await _apiService.get('/auth/me');
        if (userRes.isOk && userRes.body?['success'] == true) {
          final userData = userRes.body['data']['user'] ?? {};
          final gym = userRes.body['data']['gym'] ?? {};
          ownerData.value = Map<String, dynamic>.from(userData);
          gymData.value = Map<String, dynamic>.from(gym);

          ownerNameController.text = userData['name'] ?? '';
          phoneController.text = userData['phone'] ?? '';
          gymNameController.text = gym['name'] ?? '';
          gymPhoneController.text = gym['phone'] ?? '';
          gymAddressController.text = gym['address'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error fetching gym profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGymProfile() async {
    if (ownerNameController.text.trim().isEmpty ||
        gymNameController.text.trim().isEmpty) {
      _showSnackbar('Validation', 'Owner name and Gym name are required', isError: true);
      return;
    }

    isSaving.value = true;
    try {
      final payload = {
        'ownerName': ownerNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'gymName': gymNameController.text.trim(),
        'gymPhone': gymPhoneController.text.trim(),
        'gymAddress': gymAddressController.text.trim(),
      };

      final response = await _apiService.updateGymProfile(payload);
      if (response.isOk && response.body?['success'] == true) {
        final data = response.body['data'] ?? {};
        ownerData.value = Map<String, dynamic>.from(data['owner'] ?? {});
        gymData.value = Map<String, dynamic>.from(data['gym'] ?? {});

        // Sync with OwnerDashboardController if active
        if (Get.isRegistered<OwnerDashboardController>()) {
          final dashboard = Get.find<OwnerDashboardController>();
          dashboard.ownerName.value = ownerNameController.text.trim();
          dashboard.gymName.value = gymNameController.text.trim();
          dashboard.gymPhone.value = gymPhoneController.text.trim();
          dashboard.gymAddress.value = gymAddressController.text.trim();
        }

        _showSnackbar('Success 🎉', 'Gym profile updated successfully!');
      } else {
        _showSnackbar(
          'Error',
          response.body?['message'] ?? 'Failed to update gym profile',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar('Error', 'Update failed: $e', isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  void logout() {
    _apiService.clearAuthData();
    Get.offAllNamed('/splash');
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1C1C22),
      colorText: Colors.white,
      borderColor: isError ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
      borderWidth: 1.5,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError
            ? Icons.error_outline_rounded
            : Icons.check_circle_outline_rounded,
        color: isError ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
      ),
    );
  }

  @override
  void onClose() {
    ownerNameController.dispose();
    phoneController.dispose();
    gymNameController.dispose();
    gymPhoneController.dispose();
    gymAddressController.dispose();
    super.onClose();
  }
}
