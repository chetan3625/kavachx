import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/member_subscription_controller.dart';
import 'package:kavachx/Model/member_plan_model.dart';

class MemberSubscriptionView extends StatelessWidget {
  const MemberSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberSubscriptionController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Obx(() {
        if (!controller.isAssociatedWithGym.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.fitness_center_rounded,
                    color: Color(0xFFA1A1AA),
                    size: 64,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Join a Gym',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You need to join a gym to view membership plans and subscriptions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Positioned(
                top: -60,
                left: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF34C759).withValues(alpha: 0.15),
                  ),
                ),
              ),
              Positioned.fill(
                child: Image.asset(
                  'asset/app_backgrounds/authscreen.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  color: const Color(0xFF0F0F12).withValues(alpha: 0.85),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async =>
                      controller.checkGymAssociationAndRefresh(),
                  color: const Color(0xFFFF3B30),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Membership & Plans',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'View active subscription or upgrade package',
                                  style: TextStyle(
                                    color: Color(0xFFA1A1AA),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // --- 1. CURRENT ACTIVE / TRIAL PLAN CARD ---
                        const Text(
                          'CURRENT STATUS',
                          style: TextStyle(
                            color: Color(0xFFFF3B30),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Obx(() {
                          final sub = controller.currentSubscription.value;

                          if (sub == null) {
                            return _GlassContainer(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFFFF9500),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'No active subscription found. Select a gym package below to activate membership.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final isTrial =
                              sub.status == 'trial' || sub.price == 0;

                          return _GlassContainer(
                            padding: const EdgeInsets.all(20),
                            borderOpacity: sub.isActive ? 0.35 : 0.15,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      sub.planName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isTrial
                                            ? const Color(
                                                0xFF007AFF,
                                              ).withValues(alpha: 0.2)
                                            : (sub.isActive
                                                  ? const Color(
                                                      0xFF34C759,
                                                    ).withValues(alpha: 0.2)
                                                  : const Color(
                                                      0xFFFF3B30,
                                                    ).withValues(alpha: 0.2)),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isTrial
                                              ? const Color(0xFF007AFF)
                                              : (sub.isActive
                                                    ? const Color(0xFF34C759)
                                                    : const Color(0xFFFF3B30)),
                                        ),
                                      ),
                                      child: Text(
                                        isTrial
                                            ? 'FREE TRIAL'
                                            : (sub.isActive
                                                  ? 'ACTIVE'
                                                  : 'EXPIRED'),
                                        style: TextStyle(
                                          color: isTrial
                                              ? const Color(0xFF007AFF)
                                              : (sub.isActive
                                                    ? const Color(0xFF34C759)
                                                    : const Color(0xFFFF3B30)),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  isTrial
                                      ? 'Free Access'
                                      : '₹${sub.price.toStringAsFixed(0)} / ${sub.durationInMonths} Mo',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isTrial
                                        ? const Color(0xFF007AFF)
                                        : const Color(0xFFFF3B30),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Divider(
                                  color: Colors.white.withValues(alpha: 0.12),
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Valid Until',
                                          style: TextStyle(
                                            color: Color(0xFFA1A1AA),
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${sub.endDate.day}/${sub.endDate.month}/${sub.endDate.year}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Trial / Plan Remaining',
                                          style: TextStyle(
                                            color: Color(0xFFA1A1AA),
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${sub.daysRemaining} Days Left',
                                          style: const TextStyle(
                                            color: Color(0xFF34C759),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 28),

                        // --- 2. BROWSE AVAILABLE PLANS ---
                        const Text(
                          'AVAILABLE GYM PACKAGES',
                          style: TextStyle(
                            color: Color(0xFFFF3B30),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF3B30),
                              ),
                            );
                          }

                          if (controller.availablePlans.isEmpty) {
                            return _GlassContainer(
                              padding: const EdgeInsets.all(20),
                              child: const Center(
                                child: Text(
                                  'No custom plans uploaded by your gym owner yet.',
                                  style: TextStyle(
                                    color: Color(0xFFA1A1AA),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.availablePlans.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final plan = controller.availablePlans[index];
                              return _PlanItemCard(
                                plan: plan,
                                onSubscribe: () => _showPaymentBottomSheet(
                                  context,
                                  controller,
                                  plan,
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showPaymentBottomSheet(
    BuildContext context,
    MemberSubscriptionController controller,
    MembershipPlanModel plan,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Checkout & Payment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${plan.durationInMonths} Month Plan',
                          style: const TextStyle(
                            color: Color(0xFFA1A1AA),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${plan.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF3B30),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Column(
                  children:
                      [
                            'UPI / Google Pay / PhonePe',
                            'Card Payment',
                            'Pay at Gym Counter',
                          ]
                          .map(
                            (method) => RadioListTile<String>(
                              title: Text(
                                method,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              value: method,
                              groupValue:
                                  controller.selectedPaymentMethod.value,
                              activeColor: const Color(0xFFFF3B30),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.selectedPaymentMethod.value = val;
                                }
                              },
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isSubscribing.value
                        ? null
                        : () => controller.processSubscription(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3B30),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSubscribing.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'PAY & SUBSCRIBE ₹${plan.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.1,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    this.borderRadius = 20,
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

class _PlanItemCard extends StatelessWidget {
  final MembershipPlanModel plan;
  final VoidCallback onSubscribe;

  const _PlanItemCard({required this.plan, required this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      opacity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '₹${plan.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF3B30),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Duration: ${plan.durationInMonths} ${plan.durationInMonths == 1 ? "Month" : "Months"}',
            style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: 8),
          Column(
            children: plan.features
                .map(
                  (feature) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF34C759),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feature,
                          style: const TextStyle(
                            color: Color(0xFFA1A1AA),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'SUBSCRIBE NOW',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
