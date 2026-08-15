import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    fetchGymProfile();
  }

  Future<void> fetchGymProfile() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getGymProfile();
      if (response.isOk && response.body?['success'] == true) {
        final data = response.body['data'] ?? {};
        ownerData.value = Map<String, dynamic>.from(data['owner'] ?? {});
        gymData.value = Map<String, dynamic>.from(data['gym'] ?? {});

        // Populate controllers
        ownerNameController.text = ownerData['name'] ?? '';
        phoneController.text = ownerData['phone'] ?? '';
        gymNameController.text = gymData['name'] ?? '';
        gymPhoneController.text = gymData['phone'] ?? '';
        gymAddressController.text = gymData['address'] ?? '';
      } else {
        _showSnackbar(
          'Error',
          response.body?['message'] ?? 'Failed to load gym profile',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar('Error', 'Connection failed: $e', isError: true);
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
