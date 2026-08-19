import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavachx/Controller/inactive_members_controller.dart';

class InactiveMembersView extends StatelessWidget {
  const InactiveMembersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InactiveMembersController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBroadcastOptionsBottomSheet(context, controller),
        backgroundColor: const Color(0xFFFF3B30),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        icon: const Icon(Icons.campaign_rounded, color: Colors.white, size: 24),
        label: Text(
          'Broadcast Reminders',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Member Inactivity Tracker',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Filter members absent for X days and send automated reminders',
              style: GoogleFonts.poppins(
                color: const Color(0xFFA1A1AA),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 16),

            // Days Filter Chips (3, 7, 15, 30 Days)
            Obx(
              () => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [3, 7, 15, 30].map((days) {
                    final isSelected =
                        controller.selectedDaysFilter.value == days;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text('Absent $days+ Days'),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFF3B30),
                        backgroundColor: const Color(0xFF1C1C22),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFA1A1AA),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (_) => controller.applyDaysFilter(days),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // List of Inactive Members
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
                  );
                }

                if (controller.filteredMembers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 56,
                          color: Color(0xFF34C759),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No members absent for ${controller.selectedDaysFilter.value}+ days',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: controller.filteredMembers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = controller.filteredMembers[index];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C22).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2A2A34)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(
                              0xFFFF3B30,
                            ).withValues(alpha: 0.15),
                            child: Text(
                              item.user.name.isNotEmpty
                                  ? item.user.name[0].toUpperCase()
                                  : 'M',
                              style: const TextStyle(
                                color: Color(0xFFFF3B30),
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
                                  item.user.name,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Absent for ${item.daysAbsent} days',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFFF3B30),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Direct Trigger Action Buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Call Button
                              IconButton(
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () =>
                                    controller.makePhoneCall(item.user.phone),
                                icon: const Icon(Icons.phone_rounded, size: 20),
                                color: const Color(0xFF34C759),
                                tooltip: 'Call Member',
                              ),
                              // SMS Button
                              IconButton(
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () =>
                                    controller.sendSMS(item.user.phone),
                                icon: const Icon(Icons.sms_rounded, size: 20),
                                color: const Color(0xFFFF9500),
                                tooltip: 'Send SMS',
                              ),
                              // WhatsApp Trigger Button
                              IconButton(
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: () => controller.triggerWhatsApp(
                                  item.user.phone,
                                  item.user.name,
                                ),
                                icon: const Icon(
                                  Icons.chat_bubble_rounded,
                                  size: 20,
                                ),
                                color: const Color(0xFF25D366),
                                tooltip: 'WhatsApp Reminder',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Glassmorphism Bottom Sheet for 3 Broadcast Options
  void _showBroadcastOptionsBottomSheet(
    BuildContext context,
    InactiveMembersController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: BoxDecoration(
                color: const Color(0xFF14141A).withValues(alpha: 0.94),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Drag Handle Bar
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AUTOMATED BROADCAST',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFF3B30),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Choose Broadcast Channel',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF3B30,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFFFF3B30,
                              ).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '${controller.filteredMembers.length} Target(s)',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFF3B30),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Obx(
                    () => Text(
                      'Dispatch automated reminders to all member(s) absent for ${controller.selectedDaysFilter.value}+ days.',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFA1A1AA),
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Loading state or Option Tiles
                  Obx(() {
                    if (controller.isBroadcasting.value) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Column(
                            children: [
                              const CircularProgressIndicator(
                                color: Color(0xFFFF3B30),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Dispatching Automated Broadcast...',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Option 1: WhatsApp Broadcast
                        _buildBroadcastTile(
                          icon: Icons.chat_bubble_rounded,
                          iconColor: const Color(0xFF25D366),
                          title: 'WhatsApp Meta Broadcast',
                          subtitle:
                              'Official Meta Business template message with dynamic placeholders',
                          badgeText: 'WhatsApp Cloud API',
                          onTap: () => controller.broadcastToInactiveMembers(
                            channel: 'whatsapp',
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Option 2: SMS Broadcast
                        _buildBroadcastTile(
                          icon: Icons.sms_rounded,
                          iconColor: const Color(0xFFFF9500),
                          title: 'SMS Text Broadcast',
                          subtitle:
                              'Instant 160-character text SMS reminder to mobile numbers',
                          badgeText: 'Twilio SMS API',
                          onTap: () => controller.broadcastToInactiveMembers(
                            channel: 'sms',
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Option 3: AI Voice Call Broadcast
                        _buildBroadcastTile(
                          icon: Icons.smart_toy_rounded,
                          iconColor: const Color(0xFF007AFF),
                          title: 'AI Voice Call Agent',
                          subtitle:
                              'Conversational AI phone call agent automatically dials members',
                          badgeText: 'Bland AI / Vapi API',
                          onTap: () => controller.broadcastToInactiveMembers(
                            channel: 'aicall',
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBroadcastTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E26).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFA1A1AA),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.inter(
                        color: iconColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: iconColor.withValues(alpha: 0.7),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}