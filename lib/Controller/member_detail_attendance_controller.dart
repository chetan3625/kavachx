import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

class MemberDetailAttendanceController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxBool isLoading = true.obs;
  final RxMap<String, dynamic> memberData = <String, dynamic>{}.obs;
  final RxInt totalCheckIns = 0.obs;
  final RxList<Map<String, dynamic>> attendanceHistory =
      <Map<String, dynamic>>[].obs;

  String memberId = '';

  void initMemberId(String id, Map<String, dynamic>? initialMemberData) {
    memberId = id;
    if (initialMemberData != null) {
      memberData.value = Map<String, dynamic>.from(initialMemberData);
    }
    fetchMemberAttendanceHistory();
  }

  Future<void> fetchMemberAttendanceHistory() async {
    if (memberId.isEmpty) return;
    isLoading.value = true;
    try {
      final response =
          await _apiService.getMemberAttendanceHistoryForOwner(memberId);
      if (response.isOk && response.body?['success'] == true) {
        final data = response.body['data'] ?? {};
        if (data['member'] != null) {
          memberData.value = Map<String, dynamic>.from(data['member']);
        }
        totalCheckIns.value = data['totalCheckIns'] ?? 0;
        final List<dynamic> historyList = data['history'] ?? [];
        attendanceHistory.value =
            List<Map<String, dynamic>>.from(historyList);
      } else {
        _showSnackbar(
          'Notice',
          response.body?['message'] ?? 'Failed to load member attendance history',
        );
      }
    } catch (e) {
      debugPrint('Error fetching member attendance history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1C1C22),
      colorText: Colors.white,
      borderColor: const Color(0xFFFF3B30),
      borderWidth: 1,
    );
  }
}
