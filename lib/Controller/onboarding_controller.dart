import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

class OnboardingController extends GetxController {
  final String role;
  OnboardingController({required this.role});

  final ApiService _apiService = Get.find<ApiService>();
  final PageController pageController = PageController();
  
  final RxInt currentStep = 0.obs;
  final RxBool isSubmitting = false.obs;

  // Personal info
  final Rx<String> selectedGender = ''.obs;
  final RxInt age = 25.obs;

  // Body stats
  final RxDouble height = 170.0.obs;
  final RxDouble currentWeight = 70.0.obs;
  final RxDouble targetWeight = 65.0.obs;

  // Hydration
  final RxDouble waterTarget = 3.0.obs;
  final RxBool waterReminder = true.obs;
  final RxInt reminderIntervalHours = 2.obs;

  // Fitness
  final Rx<String> fitnessGoal = ''.obs;

  // Owner-specific
  final gymNameController = TextEditingController();
  final gymAddressController = TextEditingController();
  final gymPhoneController = TextEditingController();

  int get totalSteps => role == 'gym_owner' ? 3 : 4;

  /// Auto-calculate water intake based on weight
  double get suggestedWaterIntake => (currentWeight.value * 0.033 * 10).round() / 10;

  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  void selectFitnessGoal(String goal) {
    fitnessGoal.value = goal;
  }

  void updateWaterFromWeight() {
    waterTarget.value = suggestedWaterIntake;
  }

  Future<void> submitOnboarding() async {
    isSubmitting.value = true;

    try {
      final data = <String, dynamic>{
        'age': age.value,
        'height': height.value,
        'currentWeightKg': currentWeight.value,
        'targetWeightKg': targetWeight.value,
        'targetWaterLitres': waterTarget.value,
        'gender': selectedGender.value,
        'fitnessGoal': fitnessGoal.value,
        'waterIntakeReminder': waterReminder.value,
        'waterReminderIntervalHours': reminderIntervalHours.value,
      };

      final response = await _apiService.completeOnboarding(data);

      isSubmitting.value = false;

      if (response.isOk && response.body != null) {
        // Update local storage with onboarded status
        final userData = _apiService.getUserData();
        if (userData != null) {
          userData['isOnboarded'] = true;
          _apiService.saveAuthPayload({'user': userData});
        }

        Get.snackbar(
          'Welcome! 🎉',
          'Your profile is all set. Let\'s crush some goals!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1C1C22),
          colorText: Colors.white,
          borderColor: const Color(0xFF34C759),
          borderWidth: 1,
        );

        // Navigate to dashboard
        await Future.delayed(const Duration(milliseconds: 500));
        if (role == 'gym_owner') {
          Get.offAllNamed('/owner-dashboard');
        } else {
          Get.offAllNamed('/member-dashboard');
        }
      } else {
        final msg = response.body?['message'] ?? 'Failed to save profile';
        Get.snackbar(
          'Error',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1C1C22),
          colorText: Colors.white,
          borderColor: const Color(0xFFFF3B30),
          borderWidth: 1,
        );
      }
    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1C1C22),
        colorText: Colors.white,
        borderColor: const Color(0xFFFF3B30),
        borderWidth: 1,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    gymNameController.dispose();
    gymAddressController.dispose();
    gymPhoneController.dispose();
    super.onClose();
  }
}
