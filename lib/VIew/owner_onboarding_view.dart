import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/owner_members_controller.dart';

class OwnerMembersView extends StatelessWidget {
  const OwnerMembersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OwnerMembersController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Gym Members',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage active gym members & subscriptions',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFA1A1AA),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => controller.fetchMembers(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Input Bar
              TextField(
                controller: controller.searchController,
                onChanged: controller.filterMembers,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by name, email or phone...',
                  hintStyle: const TextStyle(color: Color(0xFF71717A)),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFA1A1AA),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1C1C22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Members List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF3B30),
                      ),
                    );
                  }

                  if (controller.filteredMembers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 56,
                            color: Color(0xFF3F3F46),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No Active Members Found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Approved join requests will appear here.',
                            style: TextStyle(
                              color: Color(0xFFA1A1AA),
                              fontSize: 12,
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
                      final member = controller.filteredMembers[index];
                      return _buildMemberCard(member);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final String name = member['name'] ?? 'Member';
    final String phone = member['phone'] ?? 'N/A';
    final String planName = member['planName'] ?? 'Standard Plan';
    final String profileImage = member['profileImage'] ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFFF3B30).withValues(alpha: 0.2),
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage(profileImage)
                    : null,
                child: profileImage.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'M',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
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
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '📞 $phone',
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF34C759).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  planName,
                  style: const TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
