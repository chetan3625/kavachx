import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/membership_plan_controller.dart';
import 'package:kavachx/Model/member_plan_model.dart';

class MembershipPlansView extends StatelessWidget {
  const MembershipPlansView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MembershipPlanController());

    return RefreshIndicator(
      color: const Color(0xFFFF3B30),
      backgroundColor: const Color(0xFF1C1C22),
      onRefresh: () async => controller.fetchPlans(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Membership Plans',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Create and manage gym pricing packages',
                      style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
                    ),
                  ],
                ),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.30),
                      ),
                    ),
                    child: Text(
                      '${controller.plansList.length} Active',
                      style: const TextStyle(
                        color: Color(0xFFFF3B30),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- 1. TOP FORM: CREATE NEW PLAN ---
            _GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.add_card_rounded,
                        color: Color(0xFFFF3B30),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ADD NEW MEMBERSHIP PLAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Plan Name Field
                  _InputField(
                    label: 'Plan Name',
                    hint: 'e.g. Gold Quarterly Membership',
                    controller: controller.nameController,
                  ),
                  const SizedBox(height: 12),

                  // Price & Duration Row
                  Row(
                    children: [
                      Expanded(
                        child: _InputField(
                          label: 'Price (₹)',
                          hint: '1499',
                          controller: controller.priceController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InputField(
                          label: 'Duration (Months)',
                          hint: '3',
                          controller: controller.durationController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Features Input Field
                  const Text(
                    'Plan Features',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: TextField(
                            controller: controller.featureInputController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'e.g. Free Personal Trainer',
                              hintStyle: TextStyle(
                                color: Color(0xFFA1A1AA),
                                fontSize: 12,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: controller.addFeature,
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF3B30),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Feature Tags List
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        controller.currentFeatures.length,
                        (index) => Chip(
                          backgroundColor: Colors.white.withValues(alpha: 0.10),
                          label: Text(
                            controller.currentFeatures[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          deleteIcon: const Icon(
                            Icons.cancel_rounded,
                            color: Color(0xFFFF3B30),
                            size: 16,
                          ),
                          onDeleted: () => controller.removeFeature(index),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Save Plan Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : controller.createPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF3B30),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'PUBLISH PLAN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.1,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // --- 2. BOTTOM SECTION: PUBLISHED PLANS LIST ---
            const Text(
              'PUBLISHED GYM PACKAGES',
              style: TextStyle(
                color: Color(0xFFFF3B30),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
                  ),
                );
              }

              if (controller.plansList.isEmpty) {
                return _GlassContainer(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: const [
                        Icon(
                          Icons.credit_card_off_rounded,
                          color: Color(0xFFA1A1AA),
                          size: 44,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No Plans Created Yet',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Use the form above to add pricing packages for your gym.',
                          textAlign: TextAlign.center,
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
                itemCount: controller.plansList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final plan = controller.plansList[index];
                  return _PlanCard(
                    plan: plan,
                    onDelete: () => controller.deletePlan(plan.id),
                  );
                },
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final MembershipPlanModel plan;
  final VoidCallback onDelete;

  const _PlanCard({required this.plan, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
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
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFFF3B30),
                  size: 22,
                ),
                onPressed: onDelete,
                tooltip: 'Delete Plan',
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '₹${plan.price.toStringAsFixed(0)} / ${plan.durationInMonths} ${plan.durationInMonths == 1 ? "Month" : "Months"}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF3B30),
            ),
          ),
          const Divider(color: Color(0xFF2C2C35), height: 20),
          Column(
            children: plan.features
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF34C759),
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: const TextStyle(
                              color: Color(0xFFA1A1AA),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFA1A1AA),
                fontSize: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const _GlassContainer({
    required this.child,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
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
