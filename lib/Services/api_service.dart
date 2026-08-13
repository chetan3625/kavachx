import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ApiService extends GetConnect {
  static ApiService get to => Get.find();

  static const String baseUrlString =
      'https://kavachx-xc1c.onrender.com/api/v1';

  // Storage Key Constants
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _qrTokenKey = 'gym_qr_token';
  static const String _qrUrlKey = 'gym_qr_url';

  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    httpClient.baseUrl = baseUrlString;
    httpClient.timeout = const Duration(seconds: 15);

    httpClient.addAuthenticator<dynamic>((request) async {
      return request;
    });

    httpClient.addResponseModifier((request, response) {
      if (response.status.hasError && response.status.connectionError) {
        if (httpClient.baseUrl?.contains('10.77.95.199') ?? false) {
          httpClient.baseUrl = 'http://10.0.2.2:5000/api/v1';
          debugPrint(
            '[API FALLBACK] Switched baseUrl to http://10.0.2.2:5000/api/v1',
          );
        } else if (httpClient.baseUrl?.contains('10.0.2.2') ?? false) {
          httpClient.baseUrl = 'http://10.77.95.199:5000/api/v1';
          debugPrint(
            '[API FALLBACK] Switched baseUrl to http://10.77.95.199:5000/api/v1',
          );
        }
      }
      return response;
    });

    // Request Interceptor: Automatically attach Bearer token
    httpClient.addRequestModifier<dynamic>((request) {
      final token = getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('================= API REQUEST =================');
      debugPrint('METHOD: ${request.method}');
      debugPrint('URL: ${request.url}');
      debugPrint('HEADERS: ${request.headers}');

      return request;
    });

    // Response Interceptor: Log and handle global 401 Expiration
    httpClient.addResponseModifier<dynamic>((request, response) async {
      debugPrint('================= API RESPONSE =================');
      debugPrint('URL: ${request.url}');
      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('BODY: ${response.bodyString}');
      debugPrint('================================================');

      // Auto Session Expiration handling on 401
      if (response.statusCode == 401 &&
          !request.url.path.contains('/auth/login')) {
        debugPrint(
          'Token expired or unauthorized. Clearing storage and redirecting...',
        );
        clearAuthData();
        Get.offAllNamed('/splash');
        Get.snackbar(
          'Session Expired',
          'Please log in again to continue.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1C1C22),
          colorText: Colors.white,
          borderColor: const Color(0xFFFF3B30),
          borderWidth: 1,
        );
      }

      return response;
    });

    super.onInit();
  }

  // Save Token, User Data, Refresh Token, and QR Payload locally
  void saveAuthPayload(Map<String, dynamic> dataMap) {
    final String? accessToken = dataMap['accessToken'] ?? dataMap['token'];
    final String? refreshToken = dataMap['refreshToken'];
    final Map<String, dynamic>? userData = dataMap['user'] is Map
        ? Map<String, dynamic>.from(dataMap['user'])
        : null;
    final Map<String, dynamic>? qrData = dataMap['qr'] is Map
        ? Map<String, dynamic>.from(dataMap['qr'])
        : null;

    if (accessToken != null && accessToken.isNotEmpty) {
      _storage.write(_tokenKey, accessToken);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      _storage.write(_refreshTokenKey, refreshToken);
    }
    if (userData != null) {
      _storage.write(_userKey, userData);
    }
    if (qrData != null) {
      if (qrData['token'] != null) {
        _storage.write(_qrTokenKey, qrData['token']);
      }
      if (qrData['qrUrl'] != null) {
        _storage.write(_qrUrlKey, qrData['qrUrl']);
      } else if (qrData['joinUrl'] != null) {
        _storage.write(_qrUrlKey, qrData['joinUrl']);
      }
    }
    final Map<String, dynamic>? gymData = dataMap['gym'] is Map
        ? Map<String, dynamic>.from(dataMap['gym'])
        : null;
    if (gymData != null && gymData['gymToken'] != null) {
      _storage.write(_qrTokenKey, gymData['gymToken']);
    }
  }

  // Getters
  String? getToken() => _storage.read<String>(_tokenKey);
  String? getRefreshToken() => _storage.read<String>(_refreshTokenKey);
  Map<String, dynamic>? getUserData() {
    final raw = _storage.read(_userKey);
    if (raw != null && raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  String? getGymQrToken() => _storage.read<String>(_qrTokenKey);
  String? getGymQrUrl() => _storage.read<String>(_qrUrlKey);

  bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear Storage on Logout / Expiration
  void clearAuthData() {
    _storage.remove(_tokenKey);
    _storage.remove(_refreshTokenKey);
    _storage.remove(_userKey);
    _storage.remove(_qrTokenKey);
    _storage.remove(_qrUrlKey);
  }

  // ================= AUTH ENDPOINTS =================

  Future<Response> registerOwner({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String gymName,
    required String gymPhone,
    required String gymAddress,
  }) {
    return post('/auth/register-owner', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'gymName': gymName,
      'gymPhone': gymPhone,
      'gymAddress': gymAddress,
    });
  }

  Future<Response> registerMember({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    return post('/auth/register-member', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });
  }

  Future<Response> login({required String email, required String password}) {
    return post('/auth/login', {'email': email, 'password': password});
  }

  Future<Response> refresh() {
    final token = getRefreshToken();
    return post('/auth/refresh', {'refreshToken': token});
  }

  Future<Response> logout() {
    return post('/auth/logout', {});
  }

  Future<Response> getMe() {
    return get('/auth/me');
  }

  // ================= GYM ENDPOINTS =================

  Future<Response> joinRequest({required String gymToken}) {
    return post('/gyms/join-request', {'gymToken': gymToken});
  }

  Future<Response> getJoinRequests() {
    return get('/gyms/join-requests');
  }

  Future<Response> approveJoinRequest(String requestId) {
    return patch('/gyms/join-requests/$requestId/approve', {});
  }

  Future<Response> rejectJoinRequest(String requestId) {
    return patch('/gyms/join-requests/$requestId/reject', {});
  }

  // ================= MEMBERSHIP PLAN ENDPOINTS =================

  Future<Response> getMembershipPlans() {
    return get('/gyms/plans');
  }

  Future<Response> createMembershipPlan({
    required String name,
    required double price,
    required int durationInMonths,
    required List<String> features,
  }) {
    return post('/gyms/plans', {
      'name': name,
      'price': price,
      'durationInMonths': durationInMonths,
      'features': features,
    });
  }

  Future<Response> getPlanById(String planId) {
    return get('/gyms/plans/$planId');
  }

  Future<Response> updateMembershipPlan({
    required String planId,
    required String name,
    required double price,
    required int durationInMonths,
    required List<String> features,
  }) {
    return put('/gyms/plans/$planId', {
      'name': name,
      'price': price,
      'durationInMonths': durationInMonths,
      'features': features,
    });
  }

  Future<Response> deleteMembershipPlan(String planId) {
    return delete('/gyms/plans/$planId');
  }

  // ================= MEMBER DASHBOARD ENDPOINTS =================

  Future<Response> getMemberDashboardSummary() {
    return get('/members/dashboard/summary');
  }

  Future<Response> memberCheckIn({String? dateStr}) {
    final todayStr = dateStr ?? DateTime.now().toIso8601String().split('T')[0];
    return post('/members/check-in', {'dateStr': todayStr});
  }

  Future<Response> memberCheckOut() {
    return post('/members/check-out', {});
  }

  Future<Response> updateHydration(double litres) {
    return patch('/members/hydration', {'waterLitres': litres});
  }

  Future<Response> updateExerciseProgress(
    String exerciseId,
    int completedSets,
  ) {
    return patch('/members/exercises/$exerciseId/progress', {
      'completedSets': completedSets,
    });
  }

  Future<Response> addExercise({
    required String name,
    required String muscleGroup,
    required double weightInKg,
    required int repsPerSet,
    required int totalSets,
    required int durationMinutes,
    String notes = '',
  }) {
    return post('/members/exercises', {
      'name': name,
      'muscleGroup': muscleGroup,
      'weightInKg': weightInKg,
      'repsPerSet': repsPerSet,
      'totalSets': totalSets,
      'durationMinutes': durationMinutes,
      'notes': notes,
    });
  }

  Future<Response> getInactiveMembers({int days = 3}) {
    return get('/gyms/inactive-members', query: {'days': '$days'});
  }

  Future<Response> deleteExercise(String exerciseId) {
    return delete('/members/exercises/$exerciseId');
  }

  Future<Response> sendAnnouncement({
    required String title,
    required String message,
    String type = 'announcement',
  }) {
    return post('/gyms/announce', {
      'title': title,
      'message': message,
      'type': type,
    });
  }

  Future<Response> logWorkoutSummary({
    required String targetPart,
    required int totalDurationMinutes,
    required int caloriesBurned,
  }) {
    return post('/members/workout-summary', {
      'targetPart': targetPart,
      'totalDurationMinutes': totalDurationMinutes,
      'caloriesBurned': caloriesBurned,
    });
  }

  // ================= MEMBER SUBSCRIPTION ENDPOINTS =================

  Future<Response> getMemberCurrentPlan() {
    return get('/members/subscription/current');
  }

  Future<Response> getAvailableGymPlans() {
    return get('/members/plans');
  }

  Future<Response> subscribeToPlan({
    required String planId,
    required String paymentMethod,
    required double amount,
  }) {
    return post('/members/subscription/subscribe', {
      'planId': planId,
      'paymentMethod': paymentMethod,
      'amount': amount,
    });
  }

  // ================= MEMBER PROFILE ENDPOINTS =================

  Future<Response> getMemberProfile() {
    return get('/members/profile');
  }

  Future<Response> updateMemberProfile(Map<String, dynamic> data) {
    return put('/members/profile', data);
  }

  Future<Response> uploadProfileImage(String filePath) {
    final form = FormData({
      'profileImage': MultipartFile(filePath, filename: 'profile.jpg'),
    });
    return put('/members/profile/image', form);
  }

  // ================= ATTENDANCE HISTORY ENDPOINTS =================

  Future<Response> getAttendanceHistory({int page = 1, int limit = 20}) {
    return get('/members/attendance/history?page=$page&limit=$limit');
  }

  Future<Response> getAttendanceStats() {
    return get('/members/attendance/stats');
  }

  // ================= NOTIFICATION ENDPOINTS =================

  Future<Response> getNotifications({int page = 1, int limit = 20}) {
    return get('/members/notifications?page=$page&limit=$limit');
  }

  Future<Response> markNotificationRead(String id) {
    return patch('/members/notifications/$id/read', {});
  }

  Future<Response> markAllNotificationsRead() {
    return patch('/members/notifications/read-all', {});
  }

  // ================= GYM DETAILS ENDPOINT =================

  Future<Response> getMemberGymDetails() {
    return get('/members/gym');
  }

  // ================= ONBOARDING ENDPOINTS =================

  Future<Response> completeOnboarding(Map<String, dynamic> data) {
    return post('/members/onboarding', data);
  }

  // ================= FCM TOKEN ENDPOINT =================

  Future<Response> updateFcmToken(String token) {
    return put('/members/fcm-token', {'fcmToken': token});
  }
}
