import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/owner_members_controller.dart';
import 'package:kavachx/VIew/member_detail_attendance_view.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnerMembersView extends StatelessWidget {
  const OwnerMembersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OwnerMembersController());

    return RefreshIndicator(
      color: const Color(0xFFFF3B30),
      backgroundColor: const Color(0xFF1C1C22),
      onRefresh: () async => controller.fetchGymMembers(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Fixed with Expanded to prevent overflow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gym Members',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Active roster & member management',
                        style: TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.30),
                      ),
                    ),
                    child: Text(
                      '${controller.membersList.length} Active',
                      style: const TextStyle(
                        color: Color(0xFFFF3B30),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Search & Filter Box
            _GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              borderRadius: 16,
              child: TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search by name or phone...',
                  hintStyle: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
                  icon: Icon(Icons.search_rounded, color: Color(0xFFA1A1AA)),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Members Roster List
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
                  ),
                );
              }

              final filteredMembers = controller.filteredMembers;

              if (filteredMembers.isEmpty) {
                return const _GlassContainer(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          color: Color(0xFFA1A1AA),
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No Gym Members Found',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Approved join requests will appear in this active roster.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFA1A1AA),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredMembers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final member = filteredMembers[index];
                  final String name = member['name'] ?? 'Member';
                  final String phone = member['phone'] ?? '';
                  final String email = member['email'] ?? '';
                  final int streakDays = member['streakDays'] ?? 0;
                  final String goal = member['fitnessGoal'] ?? 'General';

                  return GestureDetector(
                    onTap: () => Get.to(
                      () => MemberDetailAttendanceView(
                        memberId: member['_id'] ?? '',
                        initialMemberData: member,
                      ),
                    ),
                    child: _GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Header Row
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFFF3B30)
                                    .withValues(alpha: 0.2),
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'M',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      phone.isNotEmpty ? phone : email,
                                      style: const TextStyle(
                                        color: Color(0xFFA1A1AA),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (phone.isNotEmpty)
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF34C759)
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.phone_rounded,
                                      color: Color(0xFF34C759),
                                      size: 18,
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

                          const Divider(color: Color(0xFF2C2C35), height: 20),

                          // Stats Badges Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department_rounded,
                                      color: Color(0xFFFF9500),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '$streakDays Day Streak',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Goal: ${goal.replaceAll('_', ' ').toUpperCase()}',
                                    style: const TextStyle(
                                      color: Color(0xFFA1A1AA),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ACTION BUTTON: View Attendance & Workouts
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Get.to(
                                () => MemberDetailAttendanceView(
                                  memberId: member['_id'] ?? '',
                                  initialMemberData: member,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFFF3B30),
                                side: BorderSide(
                                  color: const Color(0xFFFF3B30)
                                      .withValues(alpha: 0.4),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(
                                Icons.fitness_center_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'View Attendance & Workouts',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
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
    this.borderRadius = 20,
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
