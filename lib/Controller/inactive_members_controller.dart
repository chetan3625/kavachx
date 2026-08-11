import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Model/usr_model.dart';
import 'package:kavachx/Services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberActivityModel {
  final UserModel user;
  final int daysAbsent;
  final DateTime lastActiveDate;

  MemberActivityModel({
    required this.user,
    required this.daysAbsent,
    required this.lastActiveDate,
  });
}

class InactiveMembersController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<MemberActivityModel> allMembers = <MemberActivityModel>[].obs;
  final RxList<MemberActivityModel> filteredMembers = <MemberActivityModel>[].obs;
  final RxBool isLoading = false.obs;

  // Selected filter in days (e.g., 3, 7, 15, 30)
  final RxInt selectedDaysFilter = 3.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMembersAndActivity();
  }

  Future<void> fetchMembersAndActivity() async {
    isLoading.value = true;
    try {
      // Endpoint integration placeholder: Replace with your actual members API call
      // e.g. final response = await _apiService.getMembers();
      
      // Mock data representing members with last activity dates for testing UI
      await Future.delayed(const Duration(milliseconds: 600));
      final List<MemberActivityModel> mockList = [
        MemberActivityModel(
          user: UserModel(
            id: '1',
            name: 'Rahul Patil',
            email: 'rahul@gmail.com',
            phone: '9876543210',
            role: 'gym_member',
          ),
          daysAbsent: 5,
          lastActiveDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
        MemberActivityModel(
          user: UserModel(
            id: '2',
            name: 'Amit Shinde',
            email: 'amit@gmail.com',
            phone: '9812345678',
            role: 'gym_member',
          ),
          daysAbsent: 12,
          lastActiveDate: DateTime.now().subtract(const Duration(days: 12)),
        ),
        MemberActivityModel(
          user: UserModel(
            id: '3',
            name: 'Suresh Deshmukh',
            email: 'suresh@gmail.com',
            phone: '9765432109',
            role: 'gym_member',
          ),
          daysAbsent: 2,
          lastActiveDate: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      allMembers.value = mockList;
      applyDaysFilter(selectedDaysFilter.value);
    } catch (e) {
      debugPrint('Error fetching member activity: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void applyDaysFilter(int days) {
    selectedDaysFilter.value = days;
    filteredMembers.value = allMembers
        .where((member) => member.daysAbsent >= days)
        .toList();
  }

  // Action 1: Direct Phone Call
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showSnackbar('Error', 'Could not initiate phone call', isError: true);
    }
  }

  // Action 2: Direct SMS
  Future<void> sendSMS(String phoneNumber) async {
    final String message = Uri.encodeComponent(
      'Hey! We missed you at KavachX Gym. Your workout session is waiting for you today!',
    );
    final Uri url = Uri.parse('sms:$phoneNumber?body=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showSnackbar('Error', 'Could not open SMS app', isError: true);
    }
  }

  // Action 3: WhatsApp Trigger
  Future<void> triggerWhatsApp(String phoneNumber, String name) async {
    // Format phone number to international format without spaces/plus
    String formattedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (!formattedPhone.startsWith('91') && formattedPhone.length == 10) {
      formattedPhone = '91$formattedPhone'; // Default India prefix
    }

    final String message = Uri.encodeComponent(
      'Hi $name! We noticed you haven\'t visited KavachX Gym in the last ${selectedDaysFilter.value} days. Is everything okay? Let us know when you plan to resume your fitness routine!',
    );

    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedPhone?text=$message');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackbar('Error', 'WhatsApp application not found on device', isError: true);
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