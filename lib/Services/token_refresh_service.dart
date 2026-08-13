import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

const String fetchRefreshTokenTask = "com.kavachx.fetchRefreshTokenTask";
const String baseUrlString = 'http://10.0.2.2:5000/api/v1';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == fetchRefreshTokenTask) {
      await GetStorage.init();
      final storage = GetStorage();
      final refreshToken = storage.read<String>('refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('[WORKMANAGER] No refresh token stored. Task skipped.');
        return Future.value(true);
      }

      try {
        final response = await http.post(
          Uri.parse('$baseUrlString/auth/refresh'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $refreshToken',
          },
          body: jsonEncode({'refreshToken': refreshToken}),
        );

        debugPrint('[WORKMANAGER] Refresh status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final newAccessToken =
              data['data']?['accessToken'] ?? data['accessToken'];
          final newRefreshToken =
              data['data']?['refreshToken'] ?? data['refreshToken'];

          if (newAccessToken != null) {
            await storage.write('access_token', newAccessToken);
          }
          if (newRefreshToken != null) {
            await storage.write('refresh_token', newRefreshToken);
          }
          debugPrint(
              '[WORKMANAGER] Access token refreshed successfully in background.');
          return Future.value(true);
        } else {
          debugPrint('[WORKMANAGER] Failed to refresh token: ${response.body}');
          return Future.value(false);
        }
      } catch (e) {
        debugPrint('[WORKMANAGER] Error in background refresh: $e');
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}

class TokenRefreshService {
  static Future<void> initBackgroundRefresh() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );

    // Register periodic background task (Runs every 15 minutes)
    await Workmanager().registerPeriodicTask(
      "kavachx_periodic_refresh",
      fetchRefreshTokenTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      // Corrected to ExistingPeriodicWorkPolicy for periodic tasks
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  static Future<void> cancelBackgroundRefresh() async {
    await Workmanager().cancelAll();
  }
}