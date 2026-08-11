import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ApiService extends GetConnect {
  static ApiService get to => Get.find();

  static const String baseUrlString = 'http://10.0.2.2:5000/api/v1';

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
      if (response.statusCode == 401 && !request.url.path.contains('/auth/login')) {
        debugPrint('Token expired or unauthorized. Clearing storage and redirecting...');
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
    final String? accessToken = dataMap['accessToken'];
    final String? refreshToken = dataMap['refreshToken'];
    final Map<String, dynamic>? userData = dataMap['user'];
    final Map<String, dynamic>? qrData = dataMap['qr'];

    if (accessToken != null) {
      _storage.write(_tokenKey, accessToken);
    }
    if (refreshToken != null) {
      _storage.write(_refreshTokenKey, refreshToken);
    }
    if (userData != null) {
      _storage.write(_userKey, userData);
    }
    if (qrData != null) {
      if (qrData['token'] != null) {
        _storage.write(_qrTokenKey, qrData['token']);
      }
      if (qrData['joinUrl'] != null) {
        _storage.write(_qrUrlKey, qrData['joinUrl']);
      }
    }
  }

  // Getters
  String? getToken() => _storage.read<String>(_tokenKey);
  String? getRefreshToken() => _storage.read<String>(_refreshTokenKey);
  Map<String, dynamic>? getUserData() => _storage.read<Map<String, dynamic>>(_userKey);

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

  Future<Response> login({
    required String email,
    required String password,
  }) {
    return post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<Response> refresh() {
    final token = getRefreshToken();
    return post('/auth/refresh', {
      'refreshToken': token,
    });
  }

  Future<Response> logout() {
    return post('/auth/logout', {});
  }

  Future<Response> getMe() {
    return get('/auth/me');
  }

  // ================= GYM ENDPOINTS =================

  Future<Response> joinRequest({required String gymToken}) {
    return post('/gyms/join-request', {
      'gymToken': gymToken,
    });
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

  Future<Response> deleteMembershipPlan(String planId) {
    return delete('/gyms/plans/$planId');
  }
}