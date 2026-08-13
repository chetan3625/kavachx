import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Model/member_plan_model.dart';
import 'package:kavachx/Model/membersubscriptionmode.dart';
import 'package:kavachx/Services/api_service.dart';

class MemberSubscriptionController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final Rx<MemberSubscriptionModel?> currentSubscription =
      Rx<MemberSubscriptionModel?>(null);
  final RxList<MembershipPlanModel> availablePlans =
      <MembershipPlanModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubscribing = false.obs;
  final RxString selectedPaymentMethod = 'UPI'.obs;

  // Tracks if user is linked to a gym
  final RxBool isAssociatedWithGym = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkGymAssociationAndRefresh();
  }

  void checkGymAssociationAndRefresh() {
    final userData = _apiService.getUserData();
    if (userData != null) {
      final gymId =
          userData['gymId'] ??
          userData['gym']?['_id'] ??
          userData['gym']?['id'];
      isAssociatedWithGym.value = gymId != null && gymId.toString().isNotEmpty;
    } else {
      isAssociatedWithGym.value = false;
    }

    if (isAssociatedWithGym.value) {
      fetchSubscriptionDetails();
    }
  }

  Future<void> fetchSubscriptionDetails() async {
    isLoading.value = true;
    try {
      // 1. Fetch current active plan
      final subRes = await _apiService.getMemberCurrentPlan();
      if (subRes.isOk && subRes.body != null) {
        final subData = subRes.body['data'] ?? subRes.body;
        if (subData != null && subData['id'] != null) {
          currentSubscription.value = MemberSubscriptionModel.fromJson(subData);
        } else {
          currentSubscription.value = null;
        }
      }

      // 2. Fetch all available plans for the member's joined gym
      final plansRes = await _apiService.getAvailableGymPlans();
      if (plansRes.isOk && plansRes.body != null) {
        final List plansList = plansRes.body['data'] ?? [];
        availablePlans.value = plansList
            .map((e) => MembershipPlanModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching subscription details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processSubscription(MembershipPlanModel plan) async {
    isSubscribing.value = true;
    try {
      final response = await _apiService.subscribeToPlan(
        planId: plan.id,
        paymentMethod: selectedPaymentMethod.value,
        amount: plan.price,
      );

      if (response.isOk) {
        _showSnackbar('Subscribed!', 'Successfully subscribed to ${plan.name}');
      } else {
        _showSnackbar(
          'Error',
          response.body?['message'] ?? 'Subscription failed',
          isError: true,
        );
      }
      Get.back(); // Close payment modal
      fetchSubscriptionDetails();
    } catch (e) {
      _showSnackbar('Error', 'Subscription failed: $e', isError: true);
    } finally {
      isSubscribing.value = false;
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
}
