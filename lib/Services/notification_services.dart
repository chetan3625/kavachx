import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important announcements.',
    importance: Importance.max,
  );

  Future<NotificationService> init() async {
    // 1. Request Notification Permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('[FCM] Notification permission granted.');
    }

    // 2. Force Foreground Banners
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Setup Android Local Notification Channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationPlugin>()
        ?.createNotificationChannel(_channel);

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[FCM CLICK] Payload: ${details.payload}');
      },
    );

    // 4. Register Device FCM Token with Server
    await syncFcmToken();

    _fcm.onTokenRefresh.listen((newToken) {
      if (Get.isRegistered<ApiService>()) {
        Get.find<ApiService>().updateFcmToken(newToken);
      }
    });

    // 5. Intercept Foreground Messages & Show System + GetX Banner
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM FOREGROUND MESSAGE] ${message.notification?.title}');

      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );

        Get.snackbar(
          notification.title ?? 'Announcement 📢',
          notification.body ?? '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFFF3B30),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      }
    });

    return this;
  }

  Future<void> syncFcmToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        debugPrint('[FCM TOKEN] $token');
        if (Get.isRegistered<ApiService>()) {
          await Get.find<ApiService>().updateFcmToken(token);
        }
      }
    } catch (e) {
      debugPrint('[FCM TOKEN ERROR] $e');
    }
  }
}