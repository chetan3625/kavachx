import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/member_notification_controller.dart';
import 'package:kavachx/Model/notification_model.dart';
import 'package:intl/intl.dart';

class MemberNotificationsView extends StatelessWidget {
  const MemberNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberNotificationController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFFFF3B30),
          backgroundColor: const Color(0xFF1C1C22),
          onRefresh: () => controller.fetchNotifications(refresh: true),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'NOTIFICATIONS',
                            style: TextStyle(
                              color: Color(0xFFFF3B30),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (controller.unreadCount.value > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${controller.unreadCount.value}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (controller.unreadCount.value > 0)
                        TextButton(
                          onPressed: controller.markAllAsRead,
                          child: const Text(
                            'Mark All Read',
                            style: TextStyle(color: Color(0xFF007AFF), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (controller.notifications.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(Icons.notifications_off_outlined, color: Color(0xFFA1A1AA), size: 48),
                          SizedBox(height: 16),
                          Text(
                            'You have no notifications.',
                            style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == controller.notifications.length) {
                          if (controller.hasMore.value) {
                            controller.loadMore();
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator(color: Color(0xFFFF3B30))),
                            );
                          }
                          return const SizedBox(height: 80);
                        }
                        
                        return _buildNotificationCard(controller.notifications[index], controller);
                      },
                      childCount: controller.notifications.length + (controller.hasMore.value ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, MemberNotificationController controller) {
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'membership_expiry':
        icon = Icons.calendar_today_rounded;
        iconColor = const Color(0xFFFF9500); // Orange
        break;
      case 'payment':
        icon = Icons.payment_rounded;
        iconColor = const Color(0xFF34C759); // Green
        break;
      case 'announcement':
        icon = Icons.campaign_rounded;
        iconColor = const Color(0xFF007AFF); // Blue
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = const Color(0xFFA1A1AA); // Grey
    }

    final timeAgo = _getTimeAgo(notification.createdAt);

    return GestureDetector(
      onTap: () => controller.markAsRead(notification.id),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: notification.isRead
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: notification.isRead
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFF007AFF).withValues(alpha: 0.3),
                  width: notification.isRead ? 1 : 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (!notification.isRead) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF007AFF),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: notification.isRead ? const Color(0xFFA1A1AA) : const Color(0xFFD4D4D8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: Color(0xFF71717A),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
