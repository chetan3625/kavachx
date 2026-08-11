import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

class GymSlotModel {
  final String id;
  final String time;
  final int capacity;
  final int bookedCount;

  GymSlotModel({
    required this.id,
    required this.time,
    required this.capacity,
    required this.bookedCount,
  });

  bool get isFull => bookedCount >= capacity;
}

class MemberDashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Bottom Navigation Index (0 = Home/Check-In, 1 = Book Slot, 2 = Profile)
  final RxInt selectedBottomIndex = 0.obs;

  // State Variables
  final gymTokenController = TextEditingController();
  final RxBool isSubmittingJoin = false.obs;
  final RxBool hasJoinedGym = false.obs;
  final RxBool isCheckedIn = false.obs;
  final RxString selectedSlotId = ''.obs;

  // Mock Available Gym Slots
  final RxList<GymSlotModel> availableSlots = <GymSlotModel>[
    GymSlotModel(id: '1', time: '06:00 AM - 07:00 AM', capacity: 15, bookedCount: 12),
    GymSlotModel(id: '2', time: '07:00 AM - 08:00 AM', capacity: 15, bookedCount: 15),
    GymSlotModel(id: '3', time: '08:00 AM - 09:00 AM', capacity: 15, bookedCount: 8),
    GymSlotModel(id: '4', time: '05:00 PM - 06:00 PM', capacity: 20, bookedCount: 18),
    GymSlotModel(id: '5', time: '06:00 PM - 07:00 PM', capacity: 20, bookedCount: 20),
    GymSlotModel(id: '6', time: '07:00 PM - 08:00 PM', capacity: 20, bookedCount: 10),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _checkGymAssociation();
  }

  void _checkGymAssociation() {
    final userData = _apiService.getUserData();
    if (userData != null && userData['gymId'] != null) {
      hasJoinedGym.value = true;
    }
  }

  // 1. Submit Gym Join Request API
  Future<void> submitJoinToken() async {
    final token = gymTokenController.text.trim();
    if (token.isEmpty) {
      _showSnackbar('Error', 'Please enter a valid gym join token', isError: true);
      return;
    }

    isSubmittingJoin.value = true;
    try {
      final response = await _apiService.joinRequest(gymToken: token);
      if (response.isOk) {
        _showSnackbar('Request Sent', 'Your join request is pending gym owner approval.');
        gymTokenController.clear();
      } else {
        final msg = response.body?['message'] ?? 'Failed to send request';
        _showSnackbar('Error', msg, isError: true);
      }
    } catch (e) {
      _showSnackbar('Error', 'Connection failed: $e', isError: true);
    } finally {
      isSubmittingJoin.value = false;
    }
  }

  // 2. Check-In / Check-Out Action
  void toggleCheckIn() {
    isCheckedIn.value = !isCheckedIn.value;
    final status = isCheckedIn.value ? 'Checked In' : 'Checked Out';
    _showSnackbar('Attendance', 'Successfully $status!');
  }

  // 3. Book Slot Action
  void bookSlot(String slotId) {
    selectedSlotId.value = slotId;
    _showSnackbar('Slot Reserved', 'Your gym slot has been booked for today!');
  }

  void logoutMember() {
    _apiService.clearAuthData();
    Get.offAllNamed('/splash');
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