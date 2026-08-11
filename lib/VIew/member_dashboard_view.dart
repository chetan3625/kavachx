import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/member_dashboard_controller.dart';
import 'package:kavachx/VIew/qr_scanner_view.dart';

class MemberDashboardView extends StatelessWidget {
  const MemberDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // Fullscreen Background Image
            Positioned.fill(
              child: Image.asset(
                'asset/app_backgrounds/authscreen.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                color: const Color(0xFF0F0F12).withOpacity(0.85),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // Tab Content Router
            SafeArea(
              child: Obx(() {
                switch (controller.selectedBottomIndex.value) {
                  case 0:
                    return _buildHomeTab(context, controller);
                  case 1:
                    return _buildSlotBookingTab(context, controller);
                  case 2:
                    return _buildProfileTab(context, controller);
                  default:
                    return _buildHomeTab(context, controller);
                }
              }),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.selectedBottomIndex.value,
            onTap: (index) => controller.selectedBottomIndex.value = index,
            backgroundColor: const Color(0xFF1C1C22),
            selectedItemColor: const Color(0xFFFF3B30),
            unselectedItemColor: const Color(0xFFA1A1AA),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_rounded),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded),
                label: 'Book Slot',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          )),
    );
  }

  // --- HOME / CHECK-IN TAB ---
  Widget _buildHomeTab(BuildContext context, MemberDashboardController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Member Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage attendance and gym associations',
            style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
          ),
          const SizedBox(height: 24),

          // 1. Join Gym Card Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C22).withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A34)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.vpn_key_rounded, color: Color(0xFFFF3B30)),
                    SizedBox(width: 8),
                    Text(
                      'Join a Gym',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Add this inside the "Join a Gym" container in member_dashboard_view.dart

ElevatedButton.icon(
  onPressed: () {
    Get.to(() => const QrScannerView());
  },
  icon: const Icon(Icons.qr_code_scanner_rounded),
  label: const Text('SCAN GYM QR CODE'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFF3B30),
  ),
),
                const Text(
                  'Enter the Gym Token provided by your Gym Owner:',
                  style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.gymTokenController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'e.g. KAVACH_GYM_9921',
                    prefixIcon: Icon(Icons.domain_add_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => ElevatedButton(
                      onPressed: controller.isSubmittingJoin.value
                          ? null
                          : controller.submitJoinToken,
                      child: controller.isSubmittingJoin.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('SEND JOIN REQUEST'),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Attendance Check-In / Check-Out Widget
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C22).withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A34)),
            ),
            child: Column(
              children: [
                Obx(() => Icon(
                      controller.isCheckedIn.value
                          ? Icons.check_circle_rounded
                          : Icons.access_time_filled_rounded,
                      size: 64,
                      color: controller.isCheckedIn.value
                          ? const Color(0xFF34C759)
                          : const Color(0xFFFF9500),
                    )),
                const SizedBox(height: 12),
                Obx(() => Text(
                      controller.isCheckedIn.value
                          ? 'YOU ARE CHECKED IN'
                          : 'NOT CHECKED IN TODAY',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    )),
                const SizedBox(height: 16),
                Obx(() => ElevatedButton(
                      onPressed: controller.toggleCheckIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isCheckedIn.value
                            ? const Color(0xFFFF3B30)
                            : const Color(0xFF34C759),
                      ),
                      child: Text(controller.isCheckedIn.value ? 'CHECK OUT' : 'CHECK IN NOW'),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SLOT BOOKING TAB ---
  Widget _buildSlotBookingTab(BuildContext context, MemberDashboardController controller) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book Workout Slot',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Reserve your daily time slot to avoid gym crowding',
            style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount: controller.availableSlots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final slot = controller.availableSlots[index];
                return Obx(() {
                  final isSelected = controller.selectedSlotId.value == slot.id;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C22).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFF3B30) : const Color(0xFF2A2A34),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot.time,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${slot.bookedCount} / ${slot.capacity} Booked',
                                style: TextStyle(
                                  color: slot.isFull ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: slot.isFull ? null : () => controller.bookSlot(slot.id),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(100, 40),
                            backgroundColor: isSelected ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
                          ),
                          child: Text(
                            slot.isFull
                                ? 'FULL'
                                : isSelected
                                    ? 'BOOKED'
                                    : 'BOOK',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- PROFILE TAB ---
  Widget _buildProfileTab(BuildContext context, MemberDashboardController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Member Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          ListTile(
            tileColor: const Color(0xFF1C1C22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: const Icon(Icons.logout, color: Color(0xFFFF3B30)),
            title: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onTap: controller.logoutMember,
          ),
        ],
      ),
    );
  }
}