import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';
import 'package:kavachx/Model/attendance_history_model.dart';

class MemberAttendanceController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  RxList<AttendanceHistoryModel> attendanceRecords = <AttendanceHistoryModel>[].obs;
  RxBool isLoading = true.obs;
  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;
  RxMap<String, dynamic> stats = <String, dynamic>{}.obs;
  final RxBool isAssociatedWithGym = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkGymAssociation();
    if (isAssociatedWithGym.value) {
      fetchAttendanceStats();
      fetchAttendanceHistory();
    }
  }

  void _checkGymAssociation() {
    final userData = _apiService.getUserData();
    if (userData != null) {
      final gymId = userData['gymId'] ?? userData['gym']?['_id'];
      isAssociatedWithGym.value = gymId != null && gymId.toString().isNotEmpty;
    }
  }

  Future<void> fetchAttendanceHistory({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      attendanceRecords.clear();
      isLoading.value = true;
    } else if (!hasMore.value) {
      return;
    }

    try {
      final response = await _apiService.getAttendanceHistory(page: currentPage.value, limit: 20);
      if (response.isOk && response.body['success'] == true) {
        final List<dynamic> data = response.body['data'] ?? [];
        final List<AttendanceHistoryModel> records = data.map((e) => AttendanceHistoryModel.fromJson(e)).toList();
        
        if (records.length < 20) {
          hasMore.value = false;
        }
        
        attendanceRecords.addAll(records);
      }
    } catch (e) {
      debugPrint('Error fetching attendance history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!isLoading.value && hasMore.value) {
      currentPage.value++;
      await fetchAttendanceHistory();
    }
  }

  Future<void> fetchAttendanceStats() async {
    try {
      final response = await _apiService.getAttendanceStats();
      if (response.isOk && response.body['success'] == true) {
        stats.value = response.body['data'] ?? {};
      }
    } catch (e) {
      debugPrint('Error fetching attendance stats: $e');
    }
  }

  Future<void> refreshData() async {
    await fetchAttendanceStats();
    await fetchAttendanceHistory(refresh: true);
  }
}
