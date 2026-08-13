import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

class OwnerMembersController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  RxList<Map<String, dynamic>> allMembers = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredMembers = <Map<String, dynamic>>[].obs;
  RxBool isLoading = true.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/gyms/members');
      if (response.isOk &&
          response.body != null &&
          response.body['success'] == true) {
        final List<dynamic> rawData = response.body['data'] ?? [];
        allMembers.value = List<Map<String, dynamic>>.from(rawData);
        filteredMembers.value = allMembers;
      } else {
        Get.snackbar(
          'Notice',
          response.body?['message'] ?? 'Failed to load members',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1C1C22),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error fetching gym members: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterMembers(String query) {
    if (query.trim().isEmpty) {
      filteredMembers.value = allMembers;
      return;
    }
    final q = query.toLowerCase();
    filteredMembers.value = allMembers.where((m) {
      final name = (m['name'] ?? '').toString().toLowerCase();
      final phone = (m['phone'] ?? '').toString().toLowerCase();
      final email = (m['email'] ?? '').toString().toLowerCase();
      return name.contains(q) || phone.contains(q) || email.contains(q);
    }).toList();
  }
}
