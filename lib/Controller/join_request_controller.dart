import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Model/join_request_model.dart';
import 'package:kavachx/Services/api_service.dart';

class JoinRequestsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<JoinRequestModel> requests = <JoinRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString processingRequestId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getJoinRequests();

      if (response.isOk && response.body != null) {
        final data = response.body;
        final List list = data['requests'] ?? data['data'] ?? [];
        requests.value =
            list.map((json) => JoinRequestModel.fromJson(json)).toList();
      } else {
        _showSnackbar('Error', 'Failed to fetch join requests', isError: true);
      }
    } catch (e) {
      _showSnackbar('Error', 'Connection failed: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveRequest(String requestId) async {
    processingRequestId.value = requestId;
    try {
      final response = await _apiService.approveJoinRequest(requestId);

      if (response.isOk) {
        requests.removeWhere((item) => item.id == requestId);
        _showSnackbar('Approved', 'Member approved and membership created.');
      } else {
        final msg = response.body?['message'] ?? 'Failed to approve request';
        _showSnackbar('Error', msg, isError: true);
      }
    } catch (e) {
      _showSnackbar('Error', 'Action failed: $e', isError: true);
    } finally {
      processingRequestId.value = '';
    }
  }

  Future<void> rejectRequest(String requestId) async {
    processingRequestId.value = requestId;
    try {
      final response = await _apiService.rejectJoinRequest(requestId);

      if (response.isOk) {
        requests.removeWhere((item) => item.id == requestId);
        _showSnackbar('Rejected', 'Member join request was declined.');
      } else {
        final msg = response.body?['message'] ?? 'Failed to reject request';
        _showSnackbar('Error', msg, isError: true);
      }
    } catch (e) {
      _showSnackbar('Error', 'Action failed: $e', isError: true);
    } finally {
      processingRequestId.value = '';
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