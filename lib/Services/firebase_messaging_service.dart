import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

class FirebaseMessagingService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<FirebaseMessagingService> init() async {
    // Request notification permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get and save FCM token
      await _getAndSaveToken();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToServer);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    }

    return this;
  }

  Future<void> _getAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[FCM] Token: $token');
        await _saveTokenToServer(token);
      }
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
    }
  }

  Future<void> _saveTokenToServer(String token) async {
    try {
      final apiService = Get.find<ApiService>();
      if (apiService.isLoggedIn()) {
        await apiService.updateFcmToken(token);
        debugPrint('[FCM] Token saved to server');
      }
    } catch (e) {
      debugPrint('[FCM] Error saving token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground message: ${message.notification?.title}');

    if (message.notification != null) {
      Get.snackbar(
        message.notification!.title ?? 'Notification',
        message.notification!.body ?? '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1C1C22),
        colorText: Colors.white,
        borderColor: const Color(0xFF007AFF),
        borderWidth: 1,
        icon: const Icon(Icons.notifications_rounded, color: Color(0xFF007AFF)),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] Message opened app: ${message.data}');
    final type = message.data['type'];
    if (type == 'water_reminder' || type == 'general') {
      // Navigate to notifications tab
    }
  }
}
