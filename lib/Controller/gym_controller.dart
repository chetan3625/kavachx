import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Model/join_request_model.dart';
import 'package:kavachx/Services/api_service.dart';

class GymController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<JoinRequestModel> joinRequests = <JoinRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final gymTokenController = TextEditingController();

  // Member sends join request
  Future<void> submitJoinRequest() async {
    if (gymTokenController.text.trim().isEmpty) {
      _showSnackbar('Error', 'Please enter a valid gym token', isError: true);
      return;
    }

    isLoading.value = true;
    final response = await _apiService.joinRequest(
      gymToken: gymTokenController.text.trim(),
    );
    isLoading.value = false;

    if (response.isOk) {
      _showSnackbar('Submitted', 'Join request sent to Gym Owner');
      gymTokenController.clear();
    } else {
      _showSnackbar('Error', response.body?['message'] ?? 'Request failed', isError: true);
    }
  }

  // Owner fetches pending requests
  Future<void> fetchJoinRequests() async {
    isLoading.value = true;
    final response = await _apiService.getJoinRequests();
    isLoading.value = false;

    if (response.isOk && response.body != null) {
      final List list = response.body['requests'] ?? response.body;
      joinRequests.value = list.map((e) => JoinRequestModel.fromJson(e)).toList();
    } else {
      _showSnackbar('Error', 'Failed to fetch join requests', isError: true);
    }
  }

  // Owner approves request
  Future<void> approveRequest(String requestId) async {
    final response = await _apiService.approveJoinRequest(requestId);
    if (response.isOk) {
      joinRequests.removeWhere((item) => item.id == requestId);
      _showSnackbar('Approved', 'Member added to gym');
    }
  }

  // Owner rejects request
  Future<void> rejectRequest(String requestId) async {
    final response = await _apiService.rejectJoinRequest(requestId);
    if (response.isOk) {
      joinRequests.removeWhere((item) => item.id == requestId);
      _showSnackbar('Rejected', 'Join request declined');
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
    gymTokenController.dispose();
    super.onClose();
  }
}