import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Model/member_plan_model.dart';
import 'package:kavachx/Services/api_service.dart';

class MembershipPlanController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<MembershipPlanModel> plansList = <MembershipPlanModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // Form Controllers
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
        final List data = response.body['data'] ?? [];
        plansList.value = data
            .map((e) => MembershipPlanModel.fromJson(e))
            .toList();
      } else {
        plansList.clear();
      }
    } catch (e) {
      debugPrint('[MembershipPlanController] Error fetching plans: $e');
      plansList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void addFeature() {
    final text = featureInputController.text.trim();
    if (text.isNotEmpty) {
      currentFeatures.add(text);
      featureInputController.clear();
    }
  }

  void removeFeature(int index) {
    if (index >= 0 && index < currentFeatures.length) {
      currentFeatures.removeAt(index);
    }
  }

  bool get isEditing => false;
  Future<void> savePlan() => createPlan();

  void clearForm() {
    nameController.clear();
    priceController.clear();
    durationController.clear();
    featureInputController.clear();
    currentFeatures.clear();
  }

  Future<void> createPlan() async {
    final String name = nameController.text.trim();
    final double? price = double.tryParse(priceController.text.trim());
    final int? duration = int.tryParse(durationController.text.trim());

    if (name.isEmpty) {
      _showSnackbar('Error', 'Please enter a plan name', isError: true);
      return;
    }
    if (price == null || price < 0) {
      _showSnackbar(
        'Error',
        'Please enter a valid non-negative price',
        isError: true,
      );
      return;
    }
    if (duration == null || duration < 1) {
      _showSnackbar(
        'Error',
        'Please enter a valid duration in months (min 1)',
        isError: true,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      final response = await _apiService.createMembershipPlan(
        name: name,
        price: price,
        durationInMonths: duration,
        features: currentFeatures.isNotEmpty
            ? currentFeatures
            : ['Full Gym Access'],
      );

      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        _showSnackbar('Success 🎉', 'Membership plan created successfully');
        clearForm();
        await fetchPlans();
      } else {
        final msg = response.body?['message'] ?? 'Failed to create plan';
        _showSnackbar('Error', msg, isError: true);
      }
    } catch (e) {
      debugPrint('Error creating plan: $e');
      _showSnackbar('Error', 'Something went wrong. Try again.', isError: true);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      final response = await _apiService.deleteMembershipPlan(planId);
      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        plansList.removeWhere((p) => p.id == planId);
        plansList.refresh();
        _showSnackbar('Deleted', 'Plan removed');
      } else {
        final msg = response.body?['message'] ?? 'Failed to delete plan';
        _showSnackbar('Error', msg, isError: true);
      }
    } catch (e) {
      debugPrint('Error deleting plan: $e');
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
    nameController.dispose();
    priceController.dispose();
    durationController.dispose();
    featureInputController.dispose();
    super.onClose();
  }
}
