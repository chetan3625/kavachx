import 'package:get/get.dart';

class ApiService extends GetConnect {
  static ApiService get to => Get.find();

  // For Android Emulator use http://10.0.2.2:5000/api/v1
  // For Real Device / Linux use http://localhost:5000/api/v1 or your local IP
  static const String baseUrlString = 'http://10.0.2.2:5000/api/v1';

  String? accessToken;

  @override
  void onInit() {
    httpClient.baseUrl = baseUrlString;
    httpClient.timeout = const Duration(seconds: 15);

    // Request Interceptor: Inject Bearer Token
    httpClient.addRequestModifier<dynamic>((request) {
      if (accessToken != null && accessToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }
      return request;
    });

    super.onInit();
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
    return post('/auth/refresh', {});
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
}