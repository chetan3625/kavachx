import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kavachx/Controller/member_detail_attendance_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberDetailAttendanceView extends StatefulWidget {
  final String memberId;
  final Map<String, dynamic>? initialMemberData;

  const MemberDetailAttendanceView({
    super.key,
    required this.memberId,
    this.initialMemberData,
  });

  @override
  State<MemberDetailAttendanceView> createState() =>
      _MemberDetailAttendanceViewState();
}

class _MemberDetailAttendanceViewState
    extends State<MemberDetailAttendanceView> {
  late MemberDetailAttendanceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      MemberDetailAttendanceController(),
      tag: widget.memberId,
    );
    controller.initMemberId(widget.memberId, widget.initialMemberData);
  }

  String _formatTime(dynamic dateVal) {
    if (dateVal == null) return '-';
    try {
      final DateTime dt = DateTime.parse(dateVal.toString()).toLocal();
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return dateVal.toString();
    }
  }

  String _formatDate(dynamic dateVal) {
    if (dateVal == null) return '-';
    try {
      final DateTime dt = DateTime.parse(dateVal.toString()).toLocal();
      return DateFormat('EEEE, dd MMM yyyy').format(dt);
    } catch (_) {
      return dateVal.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Member Activity & Attendance',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // Ambient Background Blobs
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF007AFF).withValues(alpha: 0.12),
                ),
              ),
            ),

            // Background Texture
            Positioned.fill(
              child: Image.asset(
                'asset/app_backgrounds/authscreen.jpg',
                fit: BoxFit.cover,
                color: const Color(0xFF0F0F12).withValues(alpha: 0.85),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            SafeArea(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.memberData.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
                  );
                }

                final member = controller.memberData;
                final String name = member['name'] ?? 'Gym Member';
                final String phone = member['phone'] ?? '';
                final String email = member['email'] ?? '';
                final int streakDays = member['streakDays'] ?? 0;

                return RefreshIndicator(
                  color: const Color(0xFFFF3B30),
                  backgroundColor: const Color(0xFF1C1C22),
                  onRefresh: controller.fetchMemberAttendanceHistory,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // MEMBER PROFILE SUMMARY HEADER CARD
                        _GlassCard(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: const Color(0xFFFF3B30)
                                        .withValues(alpha: 0.20),
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : 'M',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          email.isNotEmpty ? email : phone,
                                          style: const TextStyle(
                                            color: Color(0xFFA1A1AA),
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF9500)
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '🔥 $streakDays Day Streak',
                                                style: const TextStyle(
                                                  color: Color(0xFFFF9500),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF007AFF)
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '📅 ${controller.totalCheckIns.value} Total Check-ins',
                                                style: const TextStyle(
                                                  color: Color(0xFF007AFF),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (phone.isNotEmpty)
                                    IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF34C759)
                                              .withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.phone_rounded,
                                          color: Color(0xFF34C759),
                                          size: 20,
                                        ),
                                      ),
                                      onPressed: () async {
                                        final Uri launchUri = Uri(
                                          scheme: 'tel',
                                          path: phone,
                                        );
                                        if (await canLaunchUrl(launchUri)) {
                                          await launchUrl(launchUri);
                                        }
                                      },
                                      tooltip: 'Call Member',
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // TIMELINE SECTION TITLE
                        const Text(
                          'ATTENDANCE & WORKOUT HISTORY',
                          style: TextStyle(
                            color: Color(0xFFFF3B30),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // HISTORY LIST
                        if (controller.isLoading.value)
                          const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF3B30),
                              ),
                            ),
                          )
                        else if (controller.attendanceHistory.isEmpty)
                          _GlassCard(
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_busy_rounded,
                                        color: Color(0xFFA1A1AA),
                                        size: 44,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'No Attendance History Found',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'When this member checks in at the gym, their attendance and workout logs will appear here.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFFA1A1AA),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.attendanceHistory.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final item = controller.attendanceHistory[index];
                              final String dateStr = item['dateStr'] ?? '';
                              final String status = item['status'] ?? 'checked_in';
                              final String? targetPart = item['targetPart'];
                              final List exercises = item['exercises'] ?? [];
                              final bool isCheckedOut = status == 'checked_out';

                              return _GlassCard(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Date & Status Header
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _formatDate(
                                                    item['checkInTime'] ?? dateStr),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: (isCheckedOut
                                                        ? const Color(0xFF34C759)
                                                        : const Color(0xFFFF9500))
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: (isCheckedOut
                                                          ? const Color(0xFF34C759)
                                                          : const Color(0xFFFF9500))
                                                      .withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Text(
                                                isCheckedOut
                                                    ? 'Checked Out ✅'
                                                    : 'Checked In 🏋️‍♂️',
                                                style: TextStyle(
                                                  color: isCheckedOut
                                                      ? const Color(0xFF34C759)
                                                      : const Color(0xFFFF9500),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Timestamps Row
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time_rounded,
                                              color: Color(0xFFA1A1AA),
                                              size: 14,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Check-in: ${_formatTime(item['checkInTime'])}',
                                              style: const TextStyle(
                                                color: Color(0xFFA1A1AA),
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (item['checkOutTime'] != null) ...[
                                              const SizedBox(width: 12),
                                              const Text(
                                                '|',
                                                style: TextStyle(
                                                    color: Color(0xFF3A3A44)),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Check-out: ${_formatTime(item['checkOutTime'])}',
                                                style: const TextStyle(
                                                  color: Color(0xFFA1A1AA),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),

                                        // Target Body Part Tag if present
                                        if (targetPart != null &&
                                            targetPart.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF3B30)
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: const Color(0xFFFF3B30)
                                                    .withValues(alpha: 0.25),
                                              ),
                                            ),
                                            child: Text(
                                              '💪 Target Routine: $targetPart',
                                              style: const TextStyle(
                                                color: Color(0xFFFF3B30),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],

                                        const Divider(
                                          color: Color(0xFF2C2C35),
                                          height: 24,
                                        ),

                                        // EXERCISES LOGGED FOR THIS DAY
                                        if (exercises.isNotEmpty) ...[
                                          Text(
                                            'EXERCISES PERFORMED (${exercises.length})',
                                            style: const TextStyle(
                                              color: Color(0xFFA1A1AA),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Column(
                                            children: exercises.map((ex) {
                                              final String exName =
                                                  ex['name'] ?? 'Exercise';
                                              final String muscle =
                                                  ex['muscleGroup'] ?? '';
                                              final int totalSets =
                                                  ex['totalSets'] ?? 0;
                                              final int completedSets =
                                                  ex['completedSets'] ?? 0;
                                              final int reps =
                                                  ex['repsPerSet'] ?? 0;
                                              final num weight =
                                                  ex['weightInKg'] ?? 0;
                                              final bool exCompleted =
                                                  ex['isCompleted'] ?? false;

                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.05),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.08),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    exName,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          14,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                if (muscle
                                                                    .isNotEmpty) ...[
                                                                  const SizedBox(
                                                                      width: 6),
                                                                  Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          2,
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: const Color(
                                                                              0xFF007AFF)
                                                                          .withValues(
                                                                              alpha: 0.15),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6),
                                                                    ),
                                                                    child:
                                                                        Text(
                                                                      muscle,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Color(
                                                                            0xFF007AFF),
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 4),
                                                            Text(
                                                              '$completedSets / $totalSets Sets  •  $reps Reps${weight > 0 ? "  •  $weight kg" : ""}',
                                                              style:
                                                                  const TextStyle(
                                                                color: Color(
                                                                    0xFFA1A1AA),
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Icon(
                                                        exCompleted
                                                            ? Icons
                                                                .check_circle_rounded
                                                            : Icons
                                                                .radio_button_unchecked_rounded,
                                                        color: exCompleted
                                                            ? const Color(
                                                                0xFF34C759)
                                                            : const Color(
                                                                0xFFA1A1AA),
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ] else ...[
                                          const Text(
                                            'General Attendance (No specific exercises logged)',
                                            style: TextStyle(
                                              color: Color(0xFFA1A1AA),
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final List<Widget> children;
  const _GlassCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(children: children),
          ),
        ),
      ),
    );
  }
}
