import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/inactive_members_controller.dart';

class InactiveMembersView extends StatelessWidget {
  const InactiveMembersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InactiveMembersController());

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Member Inactivity Tracker',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Filter members absent for X days and send reminders',
            style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
          ),

          const SizedBox(height: 16),

          // Days Filter Chips (3, 7, 15, 30 Days)
          Obx(() => Row(
                children: [3, 7, 15, 30].map((days) {
                  final isSelected = controller.selectedDaysFilter.value == days;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text('Absent $days+ Days'),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFF3B30),
                      backgroundColor: const Color(0xFF1C1C22),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) => controller.applyDaysFilter(days),
                    ),
                  );
                }).toList(),
              )),

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
                        style: const TextStyle(
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
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = controller.filteredMembers[index];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C22).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A2A34)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFFF3B30).withOpacity(0.15),
                          child: Text(
                            item.user.name[0].toUpperCase(),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Absent for ${item.daysAbsent} days',
                                style: const TextStyle(
                                  color: Color(0xFFFF3B30),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Direct Trigger Action Buttons
                        Row(
                          children: [
                            // Call Button
                            IconButton(
                              onPressed: () =>
                                  controller.makePhoneCall(item.user.phone),
                              icon: const Icon(Icons.phone_rounded),
                              color: const Color(0xFF34C759),
                              tooltip: 'Call Member',
                            ),
                            // SMS Button
                            IconButton(
                              onPressed: () =>
                                  controller.sendSMS(item.user.phone),
                              icon: const Icon(Icons.sms_rounded),
                              color: const Color(0xFFFF9500),
                              tooltip: 'Send SMS',
                            ),
                            // WhatsApp Trigger Button
                            IconButton(
                              onPressed: () => controller.triggerWhatsApp(
                                item.user.phone,
                                item.user.name,
                              ),
                              icon: const Icon(Icons.chat_bubble_rounded),
                              color: const Color(0xFF25D366), // WhatsApp Green
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
    );
  }
}