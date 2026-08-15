import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/member_profile_controller.dart';
import 'package:kavachx/VIew/member_edit_profile_view.dart';

class MemberProfileView extends StatelessWidget {
  const MemberProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberProfileController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFFFF3B30),
          backgroundColor: const Color(0xFF1C1C22),
          onRefresh: controller.fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Avatar Header with Cloudinary upload
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: const Color(0xFF1C1C22),
                      backgroundImage: controller.profileImage.isNotEmpty
                          ? NetworkImage(controller.profileImage)
                          : null,
                      child: controller.profileImage.isEmpty
                          ? Text(
                              controller.name.isNotEmpty
                                  ? controller.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    if (controller.isUploadingImage.value)
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF3B30),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: controller.pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0F0F12),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  controller.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA1A1AA),
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Gym Member',
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Get.to(() => const MemberEditProfileView()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C1C22),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Personal Info Card
                _buildSectionHeader('PERSONAL INFORMATION'),
                const SizedBox(height: 10),
                _GlassCard(
                  children: [
                    _buildDataRow('Phone', controller.phone),
                    _buildDivider(),
                    _buildDataRow('Date of Birth', controller.dateOfBirth),
                    _buildDivider(),
                    _buildDataRow('Gender', controller.gender),
                    _buildDivider(),
                    _buildDataRow('Blood Group', controller.bloodGroup),
                  ],
                ),
                const SizedBox(height: 20),

                // Physical Metrics Card
                _buildSectionHeader('PHYSICAL METRICS'),
                const SizedBox(height: 10),
                _GlassCard(
                  children: [
                    _buildDataRow(
                      'Height',
                      '${controller.heightCm.toStringAsFixed(0)} cm',
                    ),
                    _buildDivider(),
                    _buildDataRow(
                      'Current Weight',
                      '${controller.currentWeightKg.toStringAsFixed(1)} kg',
                    ),
                    _buildDivider(),
                    _buildDataRow(
                      'Target Weight',
                      '${controller.targetWeightKg.toStringAsFixed(1)} kg',
                    ),
                    _buildDivider(),
                    _buildDataRow('Fitness Goal', controller.fitnessGoal),
                  ],
                ),
                const SizedBox(height: 20),

                // Health & Emergency
                _buildSectionHeader('HEALTH & EMERGENCY'),
                const SizedBox(height: 10),
                _GlassCard(
                  children: [
                    _buildDataRow(
                      'Emergency Contact',
                      controller.emergencyContact,
                    ),
                    _buildDivider(),
                    _buildDataRow(
                      'Medical Conditions',
                      controller.medicalConditions.isNotEmpty
                          ? controller.medicalConditions
                          : 'None',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Gym Information
                if (controller.gymDetails.value != null) ...[
                  _buildSectionHeader('GYM INFORMATION'),
                  const SizedBox(height: 10),
                  _GlassCard(
                    children: [
                      _buildDataRow(
                        'Gym Name',
                        controller.gymDetails.value?['name'] ?? '-',
                      ),
                      _buildDivider(),
                      _buildDataRow(
                        'Address',
                        controller.gymDetails.value?['address'] ?? '-',
                      ),
                      _buildDivider(),
                      _buildDataRow(
                        'Contact Phone',
                        controller.gymDetails.value?['phone'] ?? '-',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Logout Action
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: controller.logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF3B30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: Color(0xFFFF3B30)),
                    ),
                    child: const Text(
                      'LOGOUT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFF3B30),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
          ),
          Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.white.withValues(alpha: 0.08));
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
