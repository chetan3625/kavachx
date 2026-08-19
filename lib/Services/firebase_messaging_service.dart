import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';

import 'package:audioplayers/audioplayers.dart';

class FirebaseMessagingService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  AudioPlayer? _audioPlayer;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important announcements.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  Future<FirebaseMessagingService> init() async {
    // Request notification permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

    // Force Foreground Presentation Options
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup Local Notifications & Android Channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[FCM CLICK] Payload: ${details.payload}');
      },
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Get and save FCM token
      await syncToken();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveTokenToServer);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    }

    return this;
  }

  /// Public helper to sync FCM token with backend when user logs in or app launches
  Future<void> syncToken() async {
    await _getAndSaveToken();
  }

  Future<void> _getAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
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
        debugPrint('[FCM] Token saved to server successfully');
      }
    } catch (e) {
      debugPrint('[FCM] Error saving token: $e');
    }
  }

  Future<void> playNotificationSound() async {
    try {
      _audioPlayer ??= AudioPlayer();
      await _audioPlayer?.stop();
      await _audioPlayer?.play(AssetSource('sounds/notification_sound.mp3'));
    } catch (e) {
      debugPrint('[NotificationSound] Audio note: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      playNotificationSound();

      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
            channelShowBadge: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      Get.snackbar(
        notification.title ?? 'Notification',
        notification.body ?? '',
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
    if (type == 'water_reminder' || type == 'general' || type == 'announcement') {
      // Navigate to notifications tab if needed
    }
  }
}
