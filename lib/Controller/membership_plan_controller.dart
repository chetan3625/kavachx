import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Model/member_plan_model.dart';
import 'package:kavachx/Services/api_service.dart';

class MembershipPlansController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  RxList<MembershipPlanModel> plans = <MembershipPlanModel>[].obs;
  RxBool isLoading = true.obs;
  RxBool isSubmitting = false.obs;

  bool isEditing = false;
  String? editingPlanId;

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();
  final featureInputController = TextEditingController();

  RxList<String> currentFeatures = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/gyms/plans');
      if (response.isOk &&
          response.body is Map &&
          response.body['success'] == true) {
        final List<dynamic> rawData = response.body['data'] ?? [];
        plans.value = rawData
            .map((e) => MembershipPlanModel.fromJson(e))
            .toList();
      } else {
        debugPrint('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching membership plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    isEditing = false;
    editingPlanId = null;
    nameController.clear();
    priceController.clear();
    durationController.clear();
    featureInputController.clear();
    currentFeatures.clear();
  }

  void prepareEditForm(MembershipPlanModel plan) {
    isEditing = true;
    editingPlanId = plan.id;
    nameController.text = plan.name;
    priceController.text = plan.price.toStringAsFixed(0);
    durationController.text = plan.durationInMonths.toString();
    currentFeatures.value = List<String>.from(plan.features);
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

  Future<bool> savePlan() async {
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        durationController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please fill in plan name, price, and duration.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1C1C22),
        colorText: Colors.white,
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      final body = {
        'name': nameController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0.0,
        'durationInMonths': int.tryParse(durationController.text.trim()) ?? 1,
        'features': currentFeatures,
      };

      Response response;
      if (isEditing && editingPlanId != null) {
        response = await _apiService.put('/gyms/plans/$editingPlanId', body);
      } else {
        response = await _apiService.post('/gyms/plans', body);
      }

      if (response.isOk &&
          response.body is Map &&
          response.body['success'] == true) {
        await fetchPlans();
        clearForm();
        return true;
      } else {
        Get.snackbar(
          'Error',
          (response.body is Map)
              ? (response.body['message'] ?? 'Failed to save plan')
              : 'Failed to save plan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1C1C22),
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error saving plan: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deletePlan(String id) async {
    try {
      final response = await _apiService.delete('/gyms/plans/$id');
      if (response.isOk &&
          response.body is Map &&
          response.body['success'] == true) {
        plans.removeWhere((p) => p.id == id);
      }
    } catch (e) {
      debugPrint('Error deleting plan: $e');
    }
  }
}
