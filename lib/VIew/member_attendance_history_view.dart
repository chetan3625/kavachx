import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/member_attendance_controller.dart';
import 'package:kavachx/Model/attendance_history_model.dart';
import 'package:intl/intl.dart';
import 'package:kavachx/VIew/qr_scanner_view.dart';

class MemberAttendanceHistoryView extends StatelessWidget {
  const MemberAttendanceHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberAttendanceController());

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by dashboard
      body: Obx(() {
        // Gate behind gym association with actionable QR Scanner trigger
        if (!controller.isAssociatedWithGym.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _GlassContainer(
                padding: const EdgeInsets.all(28),
                borderRadius: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Color(0xFFFF3B30),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Gym Joined',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Scan your gym\'s QR code to join and start tracking your attendance and workouts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.to(() => const QrScannerView()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 8,
                          shadowColor: const Color(
                            0xFFFF3B30,
                          ).withValues(alpha: 0.4),
                        ),
                        icon: const Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'SCAN GYM QR CODE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (controller.isLoading.value &&
            controller.attendanceRecords.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFFFF3B30),
          backgroundColor: const Color(0xFF1C1C22),
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'ATTENDANCE STATS',
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Days Attended',
                                style: TextStyle(
                                  color: Color(0xFFA1A1AA),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${controller.stats['totalDays'] ?? 0}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Avg Duration',
                                style: TextStyle(
                                  color: Color(0xFFA1A1AA),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${controller.stats['avgDurationMinutes'] ?? 0}m',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Streak',
                                style: TextStyle(
                                  color: Color(0xFFA1A1AA),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${controller.stats['currentStreak'] ?? 0}',
                                style: const TextStyle(
                                  color: Color(0xFFFF9500),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Text(
                    'HISTORY',
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              if (controller.attendanceRecords.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFFA1A1AA),
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No attendance history found.',
                            style: TextStyle(
                              color: Color(0xFFA1A1AA),
                              fontSize: 14,
                            ),
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
                        if (index == controller.attendanceRecords.length) {
                          if (controller.hasMore.value) {
                            controller.loadMore();
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFF3B30),
                                ),
                              ),
                            );
                          }
                          return const SizedBox(height: 80);
                        }

                        return _buildAttendanceCard(
                          controller.attendanceRecords[index],
                        );
                      },
                      childCount:
                          controller.attendanceRecords.length +
                          (controller.hasMore.value ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAttendanceCard(AttendanceHistoryModel record) {
    final timeFormat = DateFormat('hh:mm a');

    DateTime? date;
    try {
      date = DateTime.parse(record.dateStr);
    } catch (_) {}

    final bool isCompleted = record.status == 'checked_out';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date != null ? DateFormat('dd').format(date) : '--',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    date != null ? DateFormat('MMM').format(date) : '---',
                    style: const TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date != null
                            ? DateFormat('EEEE').format(date)
                            : record.dateStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF34C759).withValues(alpha: 0.15)
                              : const Color(0xFFFF9500).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCompleted
                                ? const Color(0xFF34C759).withValues(alpha: 0.3)
                                : const Color(
                                    0xFFFF9500,
                                  ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 3,
                              backgroundColor: isCompleted
                                  ? const Color(0xFF34C759)
                                  : const Color(0xFFFF9500),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isCompleted ? 'Completed' : 'In Progress',
                              style: TextStyle(
                                color: isCompleted
                                    ? const Color(0xFF34C759)
                                    : const Color(0xFFFF9500),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.login_rounded,
                        color: Color(0xFFA1A1AA),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record.checkInTime != null
                            ? timeFormat.format(record.checkInTime!)
                            : '--:--',
                        style: const TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFA1A1AA),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record.checkOutTime != null
                            ? timeFormat.format(record.checkOutTime!)
                            : '--:--',
                        style: const TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (record.durationMinutes != null) ...[
              const SizedBox(width: 16),
              Column(
                children: [
                  const Text(
                    'Duration',
                    style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.durationMinutes}m',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double opacity;
  final double borderOpacity;

  const _GlassContainer({
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.opacity = 0.08,
    this.borderOpacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: borderOpacity),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
