import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

class OwnerMembersController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString search = ''.obs;

  // --- ALIAS GETTERS TO SATISFY ALL VIEW REFERENCES ---
  RxList<Map<String, dynamic>> get membersList => members;
  RxString get searchQuery => search;

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/gyms/members');
      if (response.isOk && response.body != null) {
        final List data = response.body['data'] ?? [];
        members.value = data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        members.clear();
      }
    } catch (e) {
      debugPrint('[OwnerMembersController] Error fetching members: $e');
      members.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Alias method
  Future<void> fetchGymMembers() async => fetchMembers();

  List<Map<String, dynamic>> get filteredMembers {
    final query = search.value.trim().toLowerCase();
    if (query.isEmpty) {
      return members;
    }
    return members.where((m) {
      final name = (m['name'] ?? '').toString().toLowerCase();
      final phone = (m['phone'] ?? '').toString().toLowerCase();
      final email = (m['email'] ?? '').toString().toLowerCase();
      return name.contains(query) ||
          phone.contains(query) ||
          email.contains(query);
    }).toList();
  }
}
