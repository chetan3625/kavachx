import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/member_attendance_controller.dart';
import 'package:kavachx/Controller/member_subscription_controller.dart';
import 'package:kavachx/Model/exercise_model.dart';
import 'package:kavachx/Services/api_service.dart';
import 'package:kavachx/Services/socket_service.dart';

class MemberDashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxInt selectedBottomIndex = 0.obs;
  final RxBool isCheckedIn = false.obs;
  final RxBool hasCompletedTodayAttendance = false.obs;
  final RxBool isLoading = false.obs;

  // Streak & Activity Stats
  final RxInt currentStreakDays = 0.obs;
  final RxList<bool> weeklyActivity = <bool>[
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ].obs;

  // Hydration Tracker
  final RxDouble currentWaterLitres = 2.5.obs;
  final RxDouble targetWaterLitres = 4.0.obs;
  final RxInt waterGlasses = 10.obs;

  // Body Metrics
  final RxDouble currentWeightKg = 74.5.obs;
  final RxDouble targetWeightKg = 70.0.obs;

  // Exercise & Target Stats
  final RxString todayTargetPart = 'Chest & Triceps'.obs;
  final RxList<ExerciseModel> todayExercises = <ExerciseModel>[].obs;
  final RxString userFirstName = 'Member'.obs;
  final RxBool isAssociatedWithGym = false.obs;
  final RxString gymName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchDashboardData();
    _listenToRealtimeJoinApproval();
  }

  void loadUserData() {
    final userData = _apiService.getUserData();
    if (userData != null && userData['name'] != null) {
      final String fullName = userData['name'].toString().trim();
      if (fullName.isNotEmpty) {
        userFirstName.value = fullName.split(' ').first;
      }
    }
    // Check gym association
    if (userData != null) {
      final gymId =
          userData['gymId'] ??
          userData['gym']?['_id'] ??
          userData['gym']?['id'];
      isAssociatedWithGym.value = gymId != null && gymId.toString().isNotEmpty;
      if (userData['gym'] != null && userData['gym']['name'] != null) {
        gymName.value = userData['gym']['name'];
      }
    }
  }

  void _listenToRealtimeJoinApproval() {
    try {
      if (Get.isRegistered<SocketService>()) {
        final socketService = Get.find<SocketService>();
        socketService.socket.on('join_request_updated', (data) async {
          if (data != null && data is Map) {
            final String status = data['status'] ?? '';

            if (status == 'approved') {
              // 1. Fetch fresh user info from backend
              try {
                final response = await _apiService.getMe();
                if (response.isOk && response.body != null) {
                  _apiService.saveAuthPayload(response.body);
                }
              } catch (_) {}

              // 2. Refresh local state
              loadUserData();
              isAssociatedWithGym.value = true;
              await fetchDashboardData();

              // 3. Notify other active member controllers to refresh UI
              if (Get.isRegistered<MemberAttendanceController>()) {
                Get.find<MemberAttendanceController>()
                    .checkGymAssociationAndRefresh();
              }
              if (Get.isRegistered<MemberSubscriptionController>()) {
                Get.find<MemberSubscriptionController>()
                    .checkGymAssociationAndRefresh();
              }

              _showSnackbar(
                'Approved! 🎉',
                'Your gym join request was approved by the owner!',
              );
            }
          }
        });
      }
    } catch (e) {
      debugPrint('[MemberDashboardController] Socket listener error: $e');
    }
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getMemberDashboardSummary();
      if (response.isOk && response.body != null) {
        final data = response.body['data'] ?? response.body;

        isCheckedIn.value = data['isCheckedIn'] ?? false;
        currentStreakDays.value = data['streakDays'] ?? 0;
        todayTargetPart.value = data['todayTargetPart'] ?? 'Full Body';
        currentWaterLitres.value =
            (data['waterLitres'] as num?)?.toDouble() ?? 2.5;
        currentWeightKg.value =
            (data['currentWeightKg'] as num?)?.toDouble() ?? 70.0;

        if (data['weeklyActivity'] != null) {
          weeklyActivity.value = List<bool>.from(data['weeklyActivity']);
        }

        if (data['hasCompletedTodayAttendance'] != null) {
          hasCompletedTodayAttendance.value =
              data['hasCompletedTodayAttendance'];
        }

        if (data['exercises'] != null) {
          final List exList = data['exercises'];
          todayExercises.value = exList
              .map((e) => ExerciseModel.fromJson(e))
              .toList();
        } else {
          todayExercises.value = [];
        }
      } else {
        todayExercises.value = [];
      }
    } catch (e) {
      debugPrint('Error fetching dashboard summary: $e');
      todayExercises.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleCheckIn(bool status) async {
    try {
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      final response = status
          ? await _apiService.memberCheckIn(dateStr: todayStr)
          : await _apiService.memberCheckOut();

      if (response.isOk) {
        isCheckedIn.value = status;
        if (!status) {
          hasCompletedTodayAttendance.value = true;
          final todayIndex = (DateTime.now().weekday - 1) % 7;
          if (todayIndex < weeklyActivity.length) {
            weeklyActivity[todayIndex] = true;
            weeklyActivity.refresh();
          }
        }
        _showSnackbar(
          status ? 'Checked In' : 'Checked Out',
          status ? 'Welcome to the gym!' : 'Great workout session!',
          isError: !status,
        );
      } else {
        final message =
            response.body?['message'] ??
            (status ? 'Check-in failed' : 'Check-out failed');
        _showSnackbar('Notice', message, isError: true);
      }
    } catch (e) {
      _showSnackbar('Error', 'Unable to process request', isError: true);
    }
  }

  void addGlassOfWater() {
    waterGlasses.value++;
    currentWaterLitres.value += 0.25;
    _apiService.updateHydration(currentWaterLitres.value);
  }

  void incrementSet(String exerciseId) async {
    final index = todayExercises.indexWhere((e) => e.id == exerciseId);
    if (index != -1) {
      if (todayExercises[index].completedSets <
          todayExercises[index].totalSets) {
        todayExercises[index].completedSets++;
        todayExercises.refresh();
        await _apiService.updateExerciseProgress(
          exerciseId,
          todayExercises[index].completedSets,
        );
      }
    }
  }

  Future<void> addNewExercise({
    required String name,
    required String muscleGroup,
    required double weightInKg,
    required int repsPerSet,
    required int totalSets,
    required int durationMinutes,
    String notes = '',
  }) async {
    try {
      final res = await _apiService.addExercise(
        name: name,
        muscleGroup: muscleGroup,
        weightInKg: weightInKg,
        repsPerSet: repsPerSet,
        totalSets: totalSets,
        durationMinutes: durationMinutes,
        notes: notes,
      );

      if (res.isOk && res.body != null && res.body['data'] != null) {
        final newExercise = ExerciseModel.fromJson(res.body['data']);
        todayExercises.add(newExercise);
        todayExercises.refresh();
        _showSnackbar('Exercise Added', '$name added to your routine!');
      } else {
        final localEx = ExerciseModel(
          id: 'ex_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          muscleGroup: muscleGroup,
          weightInKg: weightInKg,
          repsPerSet: repsPerSet,
          totalSets: totalSets,
          completedSets: 0,
          durationMinutes: durationMinutes,
          notes: notes,
        );
        todayExercises.add(localEx);
        todayExercises.refresh();
        _showSnackbar('Exercise Added', '$name added to your routine!');
      }
    } catch (e) {
      debugPrint('Error adding exercise: $e');
    }
  }

  Future<void> removeExercise(String exerciseId) async {
    try {
      todayExercises.removeWhere((e) => e.id == exerciseId);
      todayExercises.refresh();
      await _apiService.deleteExercise(exerciseId);
      _showSnackbar('Removed', 'Exercise deleted from routine');
    } catch (e) {
      debugPrint('Error deleting exercise: $e');
    }
  }

  Future<void> saveWorkoutSummary({
    required String targetPart,
    required int durationMinutes,
    required int calories,
  }) async {
    try {
      todayTargetPart.value = targetPart;
      await _apiService.logWorkoutSummary(
        targetPart: targetPart,
        totalDurationMinutes: durationMinutes,
        caloriesBurned: calories,
      );
      _showSnackbar('Workout Saved', 'Today\'s workout summary logged!');
    } catch (e) {
      debugPrint('Error saving workout summary: $e');
    }
  }

  int get completedSetsCount =>
      todayExercises.fold(0, (sum, item) => sum + item.completedSets);

  int get totalSetsCount =>
      todayExercises.fold(0, (sum, item) => sum + item.totalSets);

  int get remainingSetsCount => totalSetsCount - completedSetsCount;

  double get workoutProgressRatio =>
      totalSetsCount == 0 ? 0.0 : completedSetsCount / totalSetsCount;

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
}
