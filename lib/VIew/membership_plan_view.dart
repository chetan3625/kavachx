import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/membership_plan_controller.dart';
import 'package:kavachx/Model/member_plan_model.dart';
import 'package:kavachx/VIew/add_edit_plan_view.dart';

class MembershipPlansView extends StatelessWidget {
  const MembershipPlansView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MembershipPlansController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.clearForm();
          showAddEditPlanSheet(context);
        },
        backgroundColor: const Color(0xFFFF3B30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tooltip: 'Add Plan',
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Padding(
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
                      children: const [
                        Text(
                          'Membership Plans',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Manage gym pricing tiers & packages',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA1A1AA),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => controller.fetchPlans(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Plans List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF3B30),
                      ),
                    );
                  }

                  if (controller.plans.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_membership_outlined,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Membership Plans Found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap the square "+" button below to create your first plan.',
                            style: TextStyle(
                              color: Color(0xFFA1A1AA),
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.plans.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final plan = controller.plans[index];
                      return _buildPlanCard(context, controller, plan);
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

  Widget _buildPlanCard(
    BuildContext context,
    MembershipPlansController controller,
    MembershipPlanModel plan,
  ) {
    return _GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      opacity: 0.08,
      borderOpacity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: Color(0xFF007AFF),
                      size: 20,
                    ),
                    onPressed: () {
                      controller.prepareEditForm(plan);
                      Get.to(
                        () => const AddEditPlanSheet(),
                      ); // Direct Navigation
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFFF3B30),
                      size: 20,
                    ),
                    onPressed: () => _confirmDelete(context, controller, plan),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${plan.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF3B30),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '/ ${plan.durationInMonths} month${plan.durationInMonths > 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA1A1AA),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (plan.features.isNotEmpty) ...[
            const Divider(color: Color(0xFF2C2C35), height: 24),
            ...plan.features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF34C759),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFE4E4E7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    MembershipPlansController controller,
    MembershipPlanModel plan,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1C1C22),
        title: const Text('Delete Plan', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${plan.name}"?',
          style: const TextStyle(color: Color(0xFFA1A1AA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePlan(plan.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF3B30)),
            ),
          ),
        ],
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
    this.borderRadius = 16,
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
