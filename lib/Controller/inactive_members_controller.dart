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

  factory MemberActivityModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userData =
        (json['user'] is Map) ? Map<String, dynamic>.from(json['user']) : json;
    return MemberActivityModel(
      user: UserModel(
        id: userData['id'] ?? userData['_id'] ?? json['_id'] ?? json['id'] ?? '',
        name: userData['name'] ?? 'Member',
        email: userData['email'] ?? '',
        phone: userData['phone'] ?? '',
        role: userData['role'] ?? 'gym_member',
      ),
      daysAbsent: json['daysAbsent'] ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.tryParse(json['lastActiveDate'].toString()) ??
                DateTime.now()
          : (json['lastActiveAt'] != null
                ? DateTime.tryParse(json['lastActiveAt'].toString()) ??
                      DateTime.now()
                : DateTime.now()),
    );
  }
}

class InactiveMembersController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<MemberActivityModel> allMembers = <MemberActivityModel>[].obs;
  final RxList<MemberActivityModel> filteredMembers =
      <MemberActivityModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isBroadcasting = false.obs;

  // Selected filter in days (e.g., 3, 7, 15, 30)
  final RxInt selectedDaysFilter = 3.obs;

  Future<void> broadcastToInactiveMembers({required String channel}) async {
    if (filteredMembers.isEmpty) {
      _showSnackbar(
        'No Target Members',
        'There are no inactive members absent for ${selectedDaysFilter.value}+ days to notify.',
        isError: true,
      );
      return;
    }

    isBroadcasting.value = true;
    try {
      final List<String> ids = filteredMembers
          .map((m) => m.user.id ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      final response = await _apiService.broadcastInactiveMembers(
        channel: channel,
        days: selectedDaysFilter.value,
        memberIds: ids.isNotEmpty ? ids : null,
      );

      if (response.isOk &&
          response.body is Map &&
          response.body['success'] == true) {
        final count = response.body['count'] ?? filteredMembers.length;
        final channelTitle = channel == 'whatsapp'
            ? 'WhatsApp'
            : channel == 'sms'
                ? 'SMS'
                : 'AI Voice Call';

        // Close bottom sheet if open
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }

        _showSnackbar(
          'Broadcast Sent! 🚀',
          '$channelTitle reminder dispatched to $count absent member(s).',
          isError: false,
        );
      } else {
        final msg = response.body is Map && response.body['message'] != null
            ? response.body['message']
            : 'Broadcast failed';
        _showSnackbar('Broadcast Error', msg, isError: true);
      }
    } catch (e) {
      _showSnackbar('Error', 'Broadcast request failed: $e', isError: true);
    } finally {
      isBroadcasting.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchMembersAndActivity();
  }

  Future<void> fetchMembersAndActivity() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getInactiveMembers(
        days: selectedDaysFilter.value,
      );

      // Ensure body is a Map before indexing keys to prevent String crash
      if (response.isOk &&
          response.body is Map &&
          response.body['success'] == true) {
        final List<dynamic> rawList = response.body['data'] ?? [];
        final fetched = rawList
            .map((item) => MemberActivityModel.fromJson(item))
            .toList();

        allMembers.value = fetched;
        filteredMembers.value = fetched;
      } else {
        String errorMsg = 'Failed to fetch inactive members';
        if (response.body is Map && response.body['message'] != null) {
          errorMsg = response.body['message'];
        } else if (response.statusCode == 404) {
          errorMsg = 'Endpoint not found. Please restart backend server.';
        }

        _showSnackbar('Notice', errorMsg, isError: true);
      }
    } catch (e) {
      debugPrint('Error fetching member activity: $e');
      _showSnackbar('Error', 'Connection failed: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }
  void applyDaysFilter(int days) {
    selectedDaysFilter.value = days;
    fetchMembersAndActivity(); // Re-fetch calculated records for selected threshold
  }

  // Action 1: Direct Phone Call
  Future<void> makePhoneCall(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) {
      _showSnackbar(
        'Error',
        'Phone number not available for this member',
        isError: true,
      );
      return;
    }
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showSnackbar('Error', 'Could not initiate phone call', isError: true);
    }
  }

  // Action 2: Direct SMS
  Future<void> sendSMS(String phoneNumber) async {
    if (phoneNumber.trim().isEmpty) {
      _showSnackbar(
        'Error',
        'Phone number not available for this member',
        isError: true,
      );
      return;
    }
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
    if (phoneNumber.trim().isEmpty) {
      _showSnackbar(
        'Error',
        'Phone number not available for this member',
        isError: true,
      );
      return;
    }

    // Format phone number to international format without spaces/plus
    String formattedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (!formattedPhone.startsWith('91') && formattedPhone.length == 10) {
      formattedPhone = '91$formattedPhone'; // Default India prefix
    }

    final String message = Uri.encodeComponent(
      'Hi $name! We noticed you haven\'t visited KavachX Gym in the last ${selectedDaysFilter.value} days. Is everything okay? Let us know when you plan to resume your fitness routine!',
    );

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$formattedPhone?text=$message',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackbar(
        'Error',
        'WhatsApp application not found on device',
        isError: true,
      );
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
