import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/owner_dashboard_controller.dart';
import 'package:kavachx/VIew/gym_qr_display_view.dart';
import 'package:kavachx/VIew/join_request_view.dart';
import 'package:kavachx/VIew/membership_plan_view.dart';
import 'package:kavachx/VIew/owner_onboarding_view.dart';
import 'package:kavachx/VIew/owner_send_announcement_dialog.dart';
import 'package:kavachx/VIew/inactive_members_view.dart';
import 'package:kavachx/VIew/owner_profile_view.dart';

class OwnerDashboardMainView extends StatelessWidget {
  const OwnerDashboardMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OwnerDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // Ambient Background Blobs
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
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
                alignment: Alignment.center,
                color: const Color(0xFF0F0F12).withValues(alpha: 0.82),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            SafeArea(
              child: Obx(() {
                switch (controller.selectedBottomIndex.value) {
                  case 0:
                    return _buildHomeTab(context, controller);
                  case 1:
                    return const OwnerMembersView();
                  case 2:
                    return const MembershipPlansView();
                  case 3:
                    return const JoinRequestsView();
                  case 4:
                    return const InactiveMembersView();
                  case 5:
                    return const OwnerProfileView();
                  default:
                    return _buildHomeTab(context, controller);
                }
              }),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Obx(
        () => _GlassContainer(
          borderRadius: 0,
          opacity: 0.10,
          borderOpacity: 0.12,
          blur: 16,
          padding: EdgeInsets.zero,
          child: BottomNavigationBar(
            currentIndex: controller.selectedBottomIndex.value,
            onTap: (index) => controller.selectedBottomIndex.value = index,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFFFF3B30),
            unselectedItemColor: const Color(0xFFA1A1AA),
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_rounded),
                label: 'Members',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.card_membership_rounded),
                label: 'Plans',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.group_add_rounded),
                    if (controller.pendingRequestsCount.value > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${controller.pendingRequestsCount.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Requests',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_off_rounded),
                label: 'Inactive',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MAIN OWNER HOME TAB ---
  Widget _buildHomeTab(
    BuildContext context,
    OwnerDashboardController controller,
  ) {
    return RefreshIndicator(
      color: const Color(0xFFFF3B30),
      backgroundColor: const Color(0xFF1C1C22),
      onRefresh: controller.fetchDashboardStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Owner ',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: controller.ownerFirstName.value,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF3B30),
                                ),
                              ),
                              const TextSpan(
                                text: ' 👑',
                                style: TextStyle(fontSize: 22),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          controller.gymName.value.isNotEmpty
                              ? controller.gymName.value
                              : 'KavachX Fitness Hub',
                          style: const TextStyle(
                            color: Color(0xFFA1A1AA),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Gym QR Code & Profile Buttons
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.to(() => const GymQrDisplayView()),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF3B30).withValues(alpha: 0.30),
                          ),
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: Color(0xFFFF3B30),
                          size: 22,
                        ),
                      ),
                      tooltip: 'Show Gym QR',
                    ),
                    IconButton(
                      onPressed: () => Get.to(() => const OwnerProfileView()),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF007AFF).withValues(alpha: 0.30),
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF007AFF),
                          size: 22,
                        ),
                      ),
                      tooltip: 'Gym Owner Profile',
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // QUICK ACTIONS BAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    color: Color(0xFFFF3B30),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                InkWell(
                  onTap: () => showSendAnnouncementBottomSheet(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.30),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.campaign_rounded,
                          color: Color(0xFFFF3B30),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Broadcast Alert',
                          style: TextStyle(
                            color: Color(0xFFFF3B30),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // DYNAMIC STATS OVERVIEW CARDS
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      title: 'Total Members',
                      value: '${controller.totalMembersCount.value}',
                      icon: Icons.people_alt_rounded,
                      iconColor: const Color(0xFF007AFF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      title: 'Today Check-ins',
                      value: '${controller.todayCheckInsCount.value}',
                      icon: Icons.how_to_reg_rounded,
                      iconColor: const Color(0xFF34C759),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.selectedBottomIndex.value = 3,
                      child: _StatTile(
                        title: 'Pending Requests',
                        value: '${controller.pendingRequestsCount.value}',
                        icon: Icons.group_add_rounded,
                        iconColor: const Color(0xFFFF9500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.selectedBottomIndex.value = 4,
                      child: _StatTile(
                        title: 'Inactive (>3d)',
                        value: '${controller.inactiveMembersCount.value}',
                        icon: Icons.person_off_rounded,
                        iconColor: const Color(0xFFFF3B30),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // PENDING JOIN REQUESTS PREVIEW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PENDING JOIN REQUESTS',
                  style: TextStyle(
                    color: Color(0xFFFF3B30),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.selectedBottomIndex.value = 3,
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFFA1A1AA),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Obx(() {
              if (controller.pendingRequestsList.isEmpty) {
                return _GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFF34C759),
                          size: 36,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'All Caught Up!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'No pending join requests right now.',
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
                itemCount: controller.pendingRequestsList.length > 3
                    ? 3
                    : controller.pendingRequestsList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final req = controller.pendingRequestsList[index];
                  return _buildRequestRow(controller, req);
                },
              );
            }),

            const SizedBox(height: 28),

            // GYM DETAILS SUMMARY CARD
            const Text(
              'GYM DETAILS & TOKEN',
              style: TextStyle(
                color: Color(0xFFFF3B30),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            Obx(
              () => _GlassContainer(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.gymName.value.isNotEmpty
                              ? controller.gymName.value
                              : 'Gym Info',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF34C759,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Active Gym',
                            style: TextStyle(
                              color: Color(0xFF34C759),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Address: ${controller.gymAddress.value.isNotEmpty ? controller.gymAddress.value : "N/A"}',
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Phone: ${controller.gymPhone.value.isNotEmpty ? controller.gymPhone.value : "N/A"}',
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 12,
                      ),
                    ),
                    const Divider(color: Color(0xFF2C2C35), height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Token: ${controller.gymToken.value}',
                            style: const TextStyle(
                              color: Color(0xFFFF3B30),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.qr_code_2_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () =>
                              Get.to(() => const GymQrDisplayView()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestRow(
    OwnerDashboardController controller,
    Map<String, dynamic> req,
  ) {
    final member = req['userId'] ?? req['memberId'] ?? {};
    final String name = member['name'] ?? 'Member';
    final String reqId = req['_id'] ?? req['id'] ?? '';

    return _GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFF3B30).withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'M',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
                    fontSize: 14,
                  ),
                ),
                Text(
                  member['phone'] ?? member['email'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF34C759),
              size: 28,
            ),
            onPressed: () => controller.approveRequest(reqId),
            tooltip: 'Approve',
          ),
          IconButton(
            icon: const Icon(
              Icons.cancel_rounded,
              color: Color(0xFFFF3B30),
              size: 28,
            ),
            onPressed: () => controller.rejectRequest(reqId),
            tooltip: 'Reject',
          ),
        ],
      ),
    );
  }
}

// Reusable Stat Tile
class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 22),
              Text(
                value,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Reusable Glassmorphism Box
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double opacity;
  final double borderOpacity;
  final double blur;

  const _GlassContainer({
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.opacity = 0.08,
    this.borderOpacity = 0.15,
    this.blur = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
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
