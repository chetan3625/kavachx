import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Services/api_service.dart';
import 'package:kavachx/Model/notification_model.dart';

class MemberNotificationController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxBool isLoading = true.obs;
  RxInt unreadCount = 0.obs;
  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      notifications.clear();
      isLoading.value = true;
    } else if (!hasMore.value) {
      return;
    }

    try {
      final response = await _apiService.getNotifications(page: currentPage.value, limit: 20);
      if (response.isOk && response.body['success'] == true) {
        final List<dynamic> data = response.body['data'] ?? [];
        final List<NotificationModel> records = data.map((e) => NotificationModel.fromJson(e)).toList();
        
        if (records.length < 20) {
          hasMore.value = false;
        }
        
        notifications.addAll(records);
        _calculateUnreadCount();
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> loadMore() async {
    if (!isLoading.value && hasMore.value) {
      currentPage.value++;
      await fetchNotifications();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !notifications[index].isRead) {
        final notification = notifications[index];
        notifications[index] = NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          isRead: true,
          createdAt: notification.createdAt,
        );
        _calculateUnreadCount();
        await _apiService.markNotificationRead(id);
      }
    } catch (e) {
      debugPrint('Error marking notification read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      for (int i = 0; i < notifications.length; i++) {
        final notification = notifications[i];
        if (!notification.isRead) {
          notifications[i] = NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            isRead: true,
            createdAt: notification.createdAt,
          );
        }
      }
      _calculateUnreadCount();
      await _apiService.markAllNotificationsRead();
    } catch (e) {
      debugPrint('Error marking all notifications read: $e');
    }
  }
}
