import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:kavachx/Services/api_service.dart';

class SocketService extends GetxService {
  static SocketService get to => Get.find<SocketService>();

  late io.Socket socket;
  final RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    initSocketConnection();
  }

  void initSocketConnection() {
    String serverUrl = ApiService.baseUrlString.replaceAll('/api/v1', '');
    debugPrint('[SOCKET.IO] Initializing socket connection to: $serverUrl');

    try {
      socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .build(),
      );

      socket.onConnect((_) {
        debugPrint('====================================================');
        debugPrint('[SOCKET.IO SUCCESS] Connected to server! Socket ID: ${socket.id}');
        debugPrint('====================================================');
        isConnected.value = true;
        joinUserRoom();
      });

      socket.onDisconnect((reason) {
        debugPrint('[SOCKET.IO DISCONNECT] Reason: $reason');
        isConnected.value = false;
      });

      socket.onConnectError((err) {
        debugPrint('[SOCKET.IO ERROR] Connection error: $err');
        if (serverUrl.contains('10.77.95.199')) {
          debugPrint('[SOCKET.IO FALLBACK] Retrying with http://10.0.2.2:5000...');
          serverUrl = 'http://10.0.2.2:5000';
          socket.io.uri = serverUrl;
          socket.connect();
        } else if (serverUrl.contains('10.0.2.2')) {
          debugPrint('[SOCKET.IO FALLBACK] Retrying with http://10.77.95.199:5000...');
          serverUrl = 'http://10.77.95.199:5000';
          socket.io.uri = serverUrl;
          socket.connect();
        }
      });

      socket.connect();
    } catch (e) {
      debugPrint('[SOCKET.IO INIT EXCEPTION] $e');
    }
  }

  void joinUserRoom() {
    final ApiService apiService = Get.find<ApiService>();
    final userData = apiService.getUserData();
    debugPrint('[SOCKET.IO] joinUserRoom called with userData: $userData');
    if (userData != null) {
      final String? userId = userData['id'] ?? userData['_id'];
      final String? role = userData['role'];
      final String? gymId = userData['gymId'] ?? userData['gym']?['id'] ?? userData['gym']?['_id'];

      if (userId != null && userId.isNotEmpty) {
        final roomName = role == 'gym_owner' ? 'owner_$userId' : 'member_$userId';
        socket.emit('join_room', roomName);
        debugPrint('[SOCKET.IO] Emitted join_room for: $roomName');

        if (role == 'gym_owner' && gymId != null && gymId.toString().isNotEmpty) {
          socket.emit('join_room', 'gym_$gymId');
          debugPrint('[SOCKET.IO] Emitted join_room for: gym_$gymId');
        }
      }
    }
  }

  void leaveUserRoom() {
    final ApiService apiService = Get.find<ApiService>();
    final userData = apiService.getUserData();
    if (userData != null) {
      final String? userId = userData['id'] ?? userData['_id'];
      final String? role = userData['role'];

      if (userId != null && userId.isNotEmpty) {
        final roomName = role == 'gym_owner' ? 'owner_$userId' : 'member_$userId';
        socket.emit('leave_room', roomName);
      }
    }
  }

  @override
  void onClose() {
    socket.dispose();
    super.onClose();
  }
}
