import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Model/member_plan_model.dart';
import 'package:kavachx/Services/api_service.dart';

class MembershipPlansController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<MembershipPlanModel> plans = <MembershipPlanModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;

  // Form Field Controllers for Create Plan
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();
  final featureInputController = TextEditingController();

  final RxList<String> currentFeatures = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getMembershipPlans();
      if (response.isOk && response.body != null) {
        final List data = response.body['data'] ?? response.body['plans'] ?? [];
        plans.value =
            data.map((json) => MembershipPlanModel.fromJson(json)).toList();
      } else {
        // Fallback initial dummy plans for UI testing
        if (plans.isEmpty) {
          plans.value = [
            MembershipPlanModel(
              id: '1',
              name: 'Monthly Starter',
              price: 1500.0,
              durationInMonths: 1,
              features: ['General Trainer', 'Cardio Access', 'Locker Room'],
            ),
            MembershipPlanModel(
              id: '2',
              name: 'Quarterly Pro',
              price: 4000.0,
              durationInMonths: 3,
              features: [
                'Personalized Workout Plan',
                'Steam Bath',
                'All Equipment Access'
              ],
            ),
          ];
        }
      }
    } catch (e) {
      debugPrint('Error fetching plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

 void addFeature() {
    final text = featureInputController.text.trim();
    if (text.isNotEmpty) {
      currentFeatures.add(text);
      currentFeatures.refresh(); // Triggers Obx rebuild
      featureInputController.clear();
    }
  }

  void removeFeature(int index) {
    currentFeatures.removeAt(index);
    currentFeatures.refresh(); // Triggers Obx rebuild
  }

  Future<void> createPlan() async {
    final name = nameController.text.trim();
    final priceStr = priceController.text.trim();
    final durationStr = durationController.text.trim();

    if (name.isEmpty || priceStr.isEmpty || durationStr.isEmpty) {
      _showSnackbar('Error', 'Please fill in all plan details', isError: true);
      return;
    }

    isCreating.value = true;

    try {
      final double price = double.parse(priceStr);
      final int duration = int.parse(durationStr);

      final response = await _apiService.createMembershipPlan(
        name: name,
        price: price,
        durationInMonths: duration,
        features: List<String>.from(currentFeatures),
      );

      if (response.isOk) {
        _showSnackbar('Success', 'Membership Plan created successfully!');
      } else {
        // Fallback local insert for UI testing when API is pending
        plans.add(MembershipPlanModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          price: price,
          durationInMonths: duration,
          features: List<String>.from(currentFeatures),
        ));
        _showSnackbar('Plan Added', 'Plan added locally (UI Mode).');
      }

      clearForm();
      Get.back(); // Close bottom sheet modal
      fetchPlans();
    } catch (e) {
      _showSnackbar('Error', 'Invalid numbers entered: $e', isError: true);
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      final response = await _apiService.deleteMembershipPlan(planId);
      if (response.isOk) {
        plans.removeWhere((item) => item.id == planId);
        _showSnackbar('Deleted', 'Plan removed.');
      } else {
        // Local removal fallback
        plans.removeWhere((item) => item.id == planId);
        _showSnackbar('Removed', 'Plan removed locally.');
      }
    } catch (e) {
      plans.removeWhere((item) => item.id == planId);
    }
  }

  void clearForm() {
    nameController.clear();
    priceController.clear();
    durationController.clear();
    featureInputController.clear();
    currentFeatures.clear();
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
    nameController.dispose();
    priceController.dispose();
    durationController.dispose();
    featureInputController.dispose();
    super.onClose();
  }
}