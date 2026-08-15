import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

class OwnerDashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Navigation State
  final RxInt selectedBottomIndex = 0.obs;

  // Loading State
  final RxBool isLoading = true.obs;

  // Gym & Owner Profile Observables
  final RxString ownerName = ''.obs;
  final RxString gymName = ''.obs;
  final RxString gymPhone = ''.obs;
  final RxString gymAddress = ''.obs;
  final RxString gymToken = ''.obs;

  // Dynamic Dashboard Stats Observables
  final RxInt totalMembersCount = 0.obs;
  final RxInt todayCheckInsCount = 0.obs;
  final RxInt pendingRequestsCount = 0.obs;
  final RxInt inactiveMembersCount = 0.obs;

  // Pending Join Requests List
  final RxList<Map<String, dynamic>> pendingRequestsList =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
  }

  // Get first name helper
  RxString get ownerFirstName {
    if (ownerName.value.isEmpty) return 'Owner'.obs;
    return ownerName.value.split(' ').first.obs;
  }

  Future<void> fetchDashboardStats() async {
    isLoading.value = true;
    try {
      // 1. Fetch Current Owner & Gym Profile
      final userRes = await _apiService.get('/auth/me');
      if (userRes.isOk && userRes.body?['success'] == true) {
        final userData = userRes.body['data']['user'] ?? {};
        final gymData = userRes.body['data']['gym'] ?? {};

        ownerName.value = userData['name'] ?? 'Owner';
        gymName.value = gymData['name'] ?? '';
        gymPhone.value = gymData['phone'] ?? '';
        gymAddress.value = gymData['address'] ?? '';
        gymToken.value = gymData['gymToken'] ?? '';
      }

      // 2. Fetch Pending Join Requests
      final requestsRes = await _apiService.get('/gyms/join-requests');
      if (requestsRes.isOk && requestsRes.body?['success'] == true) {
        final List<dynamic> reqs = requestsRes.body['data'] ?? [];
        pendingRequestsList.value = List<Map<String, dynamic>>.from(reqs);
        pendingRequestsCount.value = pendingRequestsList.length;
      }

      // 3. Fetch Total Members Count
      final membersRes = await _apiService.get('/gyms/members');
      if (membersRes.isOk && membersRes.body?['success'] == true) {
        final List<dynamic> members = membersRes.body['data'] ?? [];
        totalMembersCount.value = members.length;
      }

      // 4. Fetch Inactive Members Count (>3 days)
      final inactiveRes = await _apiService.get(
        '/gyms/inactive-members?days=3',
      );
      if (inactiveRes.isOk && inactiveRes.body?['success'] == true) {
        final List<dynamic> inactive = inactiveRes.body['data'] ?? [];
        inactiveMembersCount.value = inactive.length;
      }

      // 5. Fetch Today's Check-ins Count
      final checkInsRes = await _apiService.get('/gyms/today-checkins');
      if (checkInsRes.isOk && checkInsRes.body?['success'] == true) {
        todayCheckInsCount.value = checkInsRes.body['count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error fetching owner dashboard stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Approve Member Join Request
  Future<void> approveRequest(String requestId) async {
    try {
      final res = await _apiService.patch(
        '/gyms/join-requests/$requestId/approve',
        {},
      );
      if (res.isOk && res.body?['success'] == true) {
        pendingRequestsList.removeWhere(
          (r) => (r['_id'] ?? r['id']).toString() == requestId.toString(),
        );
        pendingRequestsCount.value = pendingRequestsList.length;
        totalMembersCount.value += 1;

        Get.snackbar(
          'Approved! 🎉',
          'Member request has been approved successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1C1C22),
          colorText: Colors.white,
          borderColor: const Color(0xFF34C759),
          borderWidth: 1,
        );
      } else {
        _showError(res.body?['message'] ?? 'Failed to approve request');
      }
    } catch (e) {
      _showError('Error processing approval: $e');
    }
  }

  // Reject Member Join Request
  Future<void> rejectRequest(String requestId) async {
    try {
      final res = await _apiService.patch(
        '/gyms/join-requests/$requestId/reject',
        {},
      );
      if (res.isOk && res.body?['success'] == true) {
        pendingRequestsList.removeWhere(
          (r) => (r['_id'] ?? r['id']).toString() == requestId.toString(),
        );
        pendingRequestsCount.value = pendingRequestsList.length;

        Get.snackbar(
          'Rejected',
          'Join request declined.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1C1C22),
          colorText: Colors.white,
          borderColor: const Color(0xFFFF3B30),
          borderWidth: 1,
        );
      } else {
        _showError(res.body?['message'] ?? 'Failed to reject request');
      }
    } catch (e) {
      _showError('Error rejecting request: $e');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1C1C22),
      colorText: Colors.white,
      borderColor: const Color(0xFFFF3B30),
      borderWidth: 1,
    );
  }
}
