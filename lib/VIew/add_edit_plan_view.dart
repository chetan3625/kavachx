import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/membership_plan_controller.dart';

/// Call this to open the add/edit plan form as a bottom sheet.
/// Call `controller.clearForm()` before this for "add", or
/// `controller.prepareEditForm(plan)` before this for "edit".
void showAddEditPlanSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // required so the sheet can grow with keyboard
    backgroundColor: Colors.transparent,
    builder: (_) => const AddEditPlanSheet(),
  );
}

class AddEditPlanSheet extends StatelessWidget {
  const AddEditPlanSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MembershipPlanController>();

    // Push content up above the keyboard.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F0F12),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header row with title + close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.isEditing
                            ? 'Edit Membership Plan'
                            : 'Create New Plan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Header Card
                  _GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF3B30,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.card_membership_rounded,
                            color: Color(0xFFFF3B30),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Plan Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Set pricing & duration for your members',
                                style: TextStyle(
                                  color: Color(0xFFA1A1AA),
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Plan Name Input
                  _buildLabel('PLAN NAME'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: controller.nameController,
                    hint: 'e.g. Monthly Premium Tier',
                    icon: Icons.title_rounded,
                  ),

                  const SizedBox(height: 16),

                  // Price & Duration Inputs
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('PRICE (₹)'),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: controller.priceController,
                              hint: '1500',
                              icon: Icons.currency_rupee_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('DURATION (MONTHS)'),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: controller.durationController,
                              hint: '1',
                              icon: Icons.calendar_month_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Features Section
                  _buildLabel('ADD PLAN FEATURES'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: controller.featureInputController,
                          hint: 'e.g. Free Trainer Assistance',
                          icon: Icons.star_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => controller.addFeature(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Feature Chips Listing
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: controller.currentFeatures.asMap().entries.map((
                        entry,
                      ) {
                        final idx = entry.key;
                        final feature = entry.value;
                        return Chip(
                          label: Text(
                            feature,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          backgroundColor: const Color(0xFF2C2C35),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white70,
                          ),
                          onDeleted: () => controller.removeFeature(idx),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save button — bounded via double.infinity, no MediaQuery
                  // width math needed inside a bottom sheet.
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () async {
                                await controller.savePlan();
                                Get.back();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    controller.isEditing
                                        ? 'UPDATE PLAN'
                                        : 'SAVE & PUBLISH PLAN',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFFF3B30),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFA1A1AA), size: 18),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF71717A)),
        filled: true,
        fillColor: const Color(0xFF1C1C22),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassContainer({required this.child, this.padding});

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
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
