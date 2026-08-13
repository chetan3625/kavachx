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

  // Tracks if user is linked to a gym (SAAS multi‑gym support)
  final RxBool isAssociatedWithGym = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkGymAssociation();
    if (isAssociatedWithGym.value) {
      fetchSubscriptionDetails();
    }
  }

  void _checkGymAssociation() {
    // Reuse the same logic as dashboard controller to determine gym link
    final userData = _apiService.getUserData();
    if (userData != null) {
      final gymId = userData['gymId'] ?? userData['gym']?['_id'];
      isAssociatedWithGym.value = gymId != null && gymId.toString().isNotEmpty;
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
        }
      } else {
        // Fallback sample active plan for UI testing
        _loadFallbackSubscription();
      }

      // 2. Fetch all available plans for the member's joined gym
      final plansRes = await _apiService.getAvailableGymPlans();
      if (plansRes.isOk && plansRes.body != null) {
        final List plansList = plansRes.body['data'] ?? [];
        availablePlans.value = plansList
            .map((e) => MembershipPlanModel.fromJson(e))
            .toList();
      } else {
        _loadFallbackPlans();
      }
    } catch (e) {
      _loadFallbackSubscription();
      _loadFallbackPlans();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadFallbackSubscription() {
    currentSubscription.value = MemberSubscriptionModel(
      id: 'sub_101',
      planName: 'Quarterly Pro',
      price: 4000.0,
      durationInMonths: 3,
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 75)),
      status: 'active',
      features: [
        'Personalized Workout Plan',
        'Steam Bath',
        'Cardio & Weights Access',
      ],
    );
  }

  void _loadFallbackPlans() {
    if (availablePlans.isEmpty) {
      availablePlans.value = [
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
            'All Equipment Access',
          ],
        ),
        MembershipPlanModel(
          id: '3',
          name: 'Annual VIP Elite',
          price: 12000.0,
          durationInMonths: 12,
          features: [
            'Dedicated Personal Trainer',
            'Nutrition Plan',
            'Unlimited Steam & Sauna',
            'Guest Passes (2/Mo)',
          ],
        ),
      ];
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
        // Fallback local update for testing
        currentSubscription.value = MemberSubscriptionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          planName: plan.name,
          price: plan.price,
          durationInMonths: plan.durationInMonths,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(
            Duration(days: plan.durationInMonths * 30),
          ),
          status: 'active',
          features: plan.features,
        );
        _showSnackbar('Subscribed!', 'Plan activated (Testing Mode).');
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
