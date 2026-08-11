import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/membership_plan_controller.dart';
import 'package:kavachx/Model/member_plan_model.dart';

class MembershipPlansView extends StatelessWidget {
  const MembershipPlansView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MembershipPlansController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () => controller.fetchPlans(),
        color: const Color(0xFFFF3B30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Sleek Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Membership Plans',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Configure subscription packages',
                        style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
                      ),
                    ],
                  ),

                  // Sleek Top Header Add Plan Button
                  InkWell(
                    onTap: () => _showAddPlanBottomSheet(context, controller),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3B30).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.add_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'New Plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Plans List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFF3B30)),
                    );
                  }

                  if (controller.plans.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.card_membership_rounded,
                            size: 56,
                            color: Color(0xFFA1A1AA),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No plans created yet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Add your first membership plan to get started',
                            style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _showAddPlanBottomSheet(context, controller),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('CREATE FIRST PLAN'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF3B30),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.plans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final plan = controller.plans[index];
                      return _PlanCard(
                        plan: plan,
                        onDelete: () => controller.deletePlan(plan.id),
                      );
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

  void _showAddPlanBottomSheet(
      BuildContext context, MembershipPlansController controller) {
    controller.clearForm();

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create Membership Plan',
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

                // Plan Name Input
                TextField(
                  controller: controller.nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Plan Name (e.g. Gold Monthly)',
                    prefixIcon: Icon(Icons.fitness_center_rounded),
                  ),
                ),
                const SizedBox(height: 12),

                // Price and Duration Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Price (₹)',
                          prefixIcon: Icon(Icons.currency_rupee_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller.durationController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Duration (Months)',
                          prefixIcon: Icon(Icons.calendar_month_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Features Section
                // REPLACE the Benefits Section inside _showAddPlanBottomSheet in lib/VIew/membership_plans_view.dart

// Features / Benefits Section
const Text(
  'Included Benefits / Features',
  style: TextStyle(
    color: Color(0xFFFF3B30),
    fontSize: 12,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 8),

Row(
  children: [
    Expanded(
      child: TextField(
        controller: controller.featureInputController,
        style: const TextStyle(color: Colors.white),
        onSubmitted: (_) => controller.addFeature(), // Allows pressing Enter on keyboard
        decoration: const InputDecoration(
          hintText: 'Add Benefit (e.g. Free Trainer)',
          prefixIcon: Icon(Icons.check_circle_outline_rounded),
        ),
      ),
    ),
    const SizedBox(width: 8),
    IconButton(
      onPressed: () {
        controller.addFeature();
      },
      icon: const Icon(Icons.add_circle_rounded),
      color: const Color(0xFFFF3B30),
      iconSize: 36,
    ),
  ],
),
const SizedBox(height: 12),

// Added Feature Chips
Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        controller.currentFeatures.length,
        (index) => Chip(
          backgroundColor: const Color(0xFF2A2A34),
          label: Text(
            controller.currentFeatures[index],
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          deleteIcon: const Icon(Icons.cancel, size: 16, color: Color(0xFFFF3B30)),
          onDeleted: () => controller.removeFeature(index),
        ),
      ),
    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Plan Item Card
class _PlanCard extends StatelessWidget {
  final MembershipPlanModel plan;
  final VoidCallback onDelete;

  const _PlanCard({required this.plan, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C22).withOpacity(0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A34)),
      ),
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
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF3B30)),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '₹${plan.price.toStringAsFixed(0)} / ${plan.durationInMonths} ${plan.durationInMonths == 1 ? "Month" : "Months"}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF3B30),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2A2A34)),
          const SizedBox(height: 8),

          // Features List
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
                          style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
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