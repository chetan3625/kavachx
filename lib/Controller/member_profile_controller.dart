import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kavachx/Services/api_service.dart';

class MemberProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  Rx<Map<String, dynamic>> profileData = Rx<Map<String, dynamic>>({});
  Rx<Map<String, dynamic>?> gymDetails = Rx<Map<String, dynamic>?>(null);
  RxBool isLoading = true.obs;
  RxBool isSaving = false.obs;
  RxBool isUploadingImage = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchGymDetails();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getMemberProfile();
      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        profileData.value = Map<String, dynamic>.from(response.body['data']);
      } else {
        _showSnackbar(
          'Error',
          response.body?['message'] ?? 'Failed to load profile',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to connect: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      final response = await _apiService.updateMemberProfile(data);
      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        // Update local profile state
        profileData.value = Map<String, dynamic>.from(response.body['data']);

        // Show success snackbar on screen
        _showSnackbar(
          'Profile Updated! 🎉',
          response.body['message'] ??
              'Your profile details have been saved successfully.',
          isError: false,
        );

        // Close edit screen and refresh profile view
        Get.back();
        fetchProfile();
      } else {
        _showSnackbar(
          'Error',
          response.body?['message'] ?? 'Failed to update profile',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar('Error', 'Operation failed: $e', isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;

      isUploadingImage.value = true;
      final response = await _apiService.uploadProfileImage(image.path);

      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        final newImageUrl = response.body['profileImage'];
        final updated = Map<String, dynamic>.from(profileData.value);
        updated['profileImage'] = newImageUrl;
        profileData.value = updated;
        _showSnackbar('Success', 'Profile picture updated successfully!');
      } else {
        _showSnackbar(
          'Error',
          response.body?['message'] ?? 'Upload failed',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackbar('Error', 'Image upload failed: $e', isError: true);
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> fetchGymDetails() async {
    try {
      final response = await _apiService.getMemberGymDetails();
      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        gymDetails.value = response.body['data'];
      }
    } catch (e) {
      debugPrint('Error fetching gym details: $e');
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

  // Structured Getters
  String get name => profileData.value['name'] ?? '';
  String get email => profileData.value['email'] ?? '';
  String get phone => profileData.value['phone'] ?? '';
  String get profileImage => profileData.value['profileImage'] ?? '';
  String get dateOfBirth => profileData.value['dateOfBirth'] != null
      ? profileData.value['dateOfBirth'].toString().split('T')[0]
      : '';
  String get gender => profileData.value['gender'] ?? '';
  String get bloodGroup => profileData.value['bloodGroup'] ?? '';
  String get emergencyContact => profileData.value['emergencyContact'] ?? '';
  String get medicalConditions => profileData.value['medicalConditions'] ?? '';
  String get fitnessGoal => profileData.value['fitnessGoal'] ?? '';
  double get heightCm =>
      (profileData.value['heightCm'] ?? profileData.value['height'] ?? 0)
          .toDouble();
  double get currentWeightKg =>
      (profileData.value['currentWeightKg'] ?? 0).toDouble();
  double get targetWeightKg =>
      (profileData.value['targetWeightKg'] ?? 0).toDouble();
}
