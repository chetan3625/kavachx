import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/owner_dashboard_controller.dart';
import 'package:kavachx/VIew/gym_qr_display_view.dart';
import 'package:kavachx/VIew/inactive_members_view.dart';
import 'package:kavachx/VIew/join_request_view.dart';
import 'package:kavachx/VIew/membership_plan_view.dart';

class OwnerDashboardView extends StatelessWidget {
  const OwnerDashboardView({Key? key}) : super(key: key);

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
            // 1. Fullscreen Background Image
            Positioned.fill(
              child: Image.asset(
                'asset/app_backgrounds/authscreen.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                color: const Color(0xFF0F0F12).withOpacity(0.85),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // 2. Main Screen Area based on selected bottom tab
            SafeArea(
              child: Obx(() {
                switch (controller.selectedBottomIndex.value) {
                  case 0:
                    return _buildHomeTab(context, controller);
                  case 1:
                    return const JoinRequestsView();
                  case 2:
                    return const MembershipPlansView();
                  case 3:
                    return const InactiveMembersView();
                  case 4:
                    return _buildProfileTab(context, controller);
                  default:
                    return _buildHomeTab(context, controller);
                }
              }),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar (5 Items)
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.selectedBottomIndex.value,
            onTap: (index) => controller.selectedBottomIndex.value = index,
            backgroundColor: const Color(0xFF1C1C22),
            selectedItemColor: const Color(0xFFFF3B30),
            unselectedItemColor: const Color(0xFFA1A1AA),
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Home',
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
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Requests',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.card_membership_rounded),
                label: 'Plans',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_rounded),
                label: 'Members',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          )),
    );
  }

  // Home Tab Widget
  Widget _buildHomeTab(BuildContext context, OwnerDashboardController controller) {
    return RefreshIndicator(
      onRefresh: () async => controller.fetchDashboardStats(),
      color: const Color(0xFFFF3B30),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar / Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          controller.gymName.value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )),
                    const SizedBox(height: 4),
                    const Text(
                      'Owner Dashboard',
                      style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
                    ),
                  ],
                ),

                // Top Right Action Icons (QR Code & Notifications)
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.to(() => const GymQrDisplayView()),
                      icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF1C1C22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF2A2A34)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2A2A34)),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Stat Cards Grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Check-Ins Today',
                    value: controller.todayCheckIns.value.toString(),
                    icon: Icons.qr_code_scanner_rounded,
                    accentColor: const Color(0xFF34C759),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => _StatCard(
                        title: 'Pending Joins',
                        value: controller.pendingRequestsCount.value.toString(),
                        icon: Icons.person_add_alt_1_rounded,
                        accentColor: const Color(0xFFFF9500),
                        onTap: () => controller.selectedBottomIndex.value = 1,
                      )),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Actions Section Header
            const Text(
              'QUICK ACTIONS',
              style: TextStyle(
                color: Color(0xFFFF3B30),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Quick Actions List
            _ActionTile(
              title: 'Manage Membership Plans',
              subtitle: 'Create and edit pricing tiers for members',
              icon: Icons.card_membership_rounded,
              onTap: () => controller.selectedBottomIndex.value = 2,
            ),
            const SizedBox(height: 12),
            _ActionTile(
              title: 'Show Gym QR Code',
              subtitle: 'Display or print QR code for members to join',
              icon: Icons.qr_code_2_rounded,
              onTap: () => Get.to(() => const GymQrDisplayView()),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              title: 'Review Join Requests',
              subtitle: 'Approve or reject pending gym members',
              icon: Icons.how_to_reg_rounded,
              onTap: () => controller.selectedBottomIndex.value = 1,
            ),
            const SizedBox(height: 12),
            _ActionTile(
              title: 'Inactive Members List',
              subtitle: 'Find members absent for X days & call/WhatsApp',
              icon: Icons.person_off_rounded,
              onTap: () => controller.selectedBottomIndex.value = 3,
            ),
          ],
        ),
      ),
    );
  }

  // Profile Tab Widget
  Widget _buildProfileTab(BuildContext context, OwnerDashboardController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          ListTile(
            tileColor: const Color(0xFF1C1C22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.qr_code_2_rounded, color: Colors.white),
            title: const Text('View Gym QR Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onTap: () => Get.to(() => const GymQrDisplayView()),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: const Color(0xFF1C1C22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.logout, color: Color(0xFFFF3B30)),
            title: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onTap: controller.logoutOwner,
          ),
        ],
      ),
    );
  }
}

// Reusable Metric Stat Card
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C22).withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A34)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFFA1A1AA)),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Action Tile Card
class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C22).withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A34)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFFF3B30), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFA1A1AA), size: 14),
          ],
        ),
      ),
    );
  }
}