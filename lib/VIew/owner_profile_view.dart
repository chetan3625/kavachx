import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/owner_profile_controller.dart';
import 'package:kavachx/VIew/gym_qr_display_view.dart';

class OwnerProfileView extends StatelessWidget {
  const OwnerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OwnerProfileController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
        );
      }

      return RefreshIndicator(
        color: const Color(0xFFFF3B30),
        backgroundColor: const Color(0xFF1C1C22),
        onRefresh: controller.fetchGymProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gym Owner Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: controller.fetchGymProfile,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFFFF3B30),
                    ),
                    tooltip: 'Refresh Profile',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage your gym info & owner account details',
                style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Owner Avatar & Badge
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF3B30), Color(0xFFFF9500)],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: const Color(0xFF1C1C22),
                        child: Text(
                          controller.ownerNameController.text.isNotEmpty
                              ? controller.ownerNameController.text[0]
                                  .toUpperCase()
                              : '👑',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.ownerNameController.text,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.ownerData['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFA1A1AA),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
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
                        'GYM OWNER & MANAGER 👑',
                        style: TextStyle(
                          color: Color(0xFFFF3B30),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // GYM DETAILS SECTION
              _buildSectionHeader('GYM DETAILS'),
              const SizedBox(height: 10),
              _GlassCard(
                children: [
                  _buildTextField(
                    controller: controller.gymNameController,
                    label: 'Gym Name',
                    icon: Icons.fitness_center_rounded,
                  ),
                  _buildDivider(),
                  _buildTextField(
                    controller: controller.gymPhoneController,
                    label: 'Gym Contact Phone',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildDivider(),
                  _buildTextField(
                    controller: controller.gymAddressController,
                    label: 'Gym Address',
                    icon: Icons.location_on_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // OWNER ACCOUNT SECTION
              _buildSectionHeader('OWNER ACCOUNT INFORMATION'),
              const SizedBox(height: 10),
              _GlassCard(
                children: [
                  _buildTextField(
                    controller: controller.ownerNameController,
                    label: 'Owner Full Name',
                    icon: Icons.person_rounded,
                  ),
                  _buildDivider(),
                  _buildTextField(
                    controller: controller.phoneController,
                    label: 'Personal Phone Number',
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // GYM QR CODE & TOKEN ACCESS
              _buildSectionHeader('GYM ACCESS & QR CODE'),
              const SizedBox(height: 10),
              _GlassCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gym Token Code',
                                style: TextStyle(
                                  color: Color(0xFFA1A1AA),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.gymData['gymToken'] ?? '-',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => Get.to(() => const GymQrDisplayView()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF3B30),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                          label: const Text(
                            'QR Code',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // SAVE CHANGES BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.updateGymProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // LOGOUT BUTTON
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
    });
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFF3B30),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFFA1A1AA), size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
          border: InputBorder.none,
        ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }
}
