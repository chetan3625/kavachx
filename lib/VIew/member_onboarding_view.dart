import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Controller/onboarding_controller.dart';

class MemberOnboardingView extends StatelessWidget {
  const MemberOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController(role: 'gym_member'));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(controller),
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(controller),
                      _buildStep2(controller),
                      _buildStep3(controller),
                      _buildStep4(controller),
                    ],
                  ),
                ),
                _buildBottomNav(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(OnboardingController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Obx(() => controller.currentStep.value > 0
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      onPressed: controller.previousStep,
                    )
                  : const SizedBox(width: 48)),
              const Spacer(),
              const Text(
                'Setup Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= controller.currentStep.value
                            ? const Color(0xFFFF3B30)
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: index <= controller.currentStep.value
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFF3B30).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBottomNav(OnboardingController controller) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Obx(() {
        final isLastStep = controller.currentStep.value == 3;
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (isLastStep) {
                controller.submitOnboarding();
              } else {
                if (controller.currentStep.value == 1) {
                  controller.updateWaterFromWeight();
                }
                controller.nextStep();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: const Color(0xFFFF3B30).withValues(alpha: 0.5),
            ),
            child: controller.isSubmitting.value
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    isLastStep ? 'Start Your Journey 🚀' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildStep1(OnboardingController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Let's Get To Know You",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Help us personalize your experience",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFA1A1AA),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            "YOUR GENDER",
            style: TextStyle(
              color: Color(0xFFFF3B30),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildGenderCard(controller, 'Male', '👨', const Color(0xFF007AFF)),
              const SizedBox(width: 12),
              _buildGenderCard(controller, 'Female', '👩', const Color(0xFFFF2D55)),
              const SizedBox(width: 12),
              _buildGenderCard(controller, 'Other', '🧑', const Color(0xFFAF52DE)),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "YOUR AGE",
            style: TextStyle(
              color: Color(0xFFFF3B30),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          _buildGlassContainer(
            child: Column(
              children: [
                Obx(() => Text(
                      '${controller.age.value}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
                const Text(
                  "years old",
                  style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
                ),
                const SizedBox(height: 16),
                Obx(() => SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: const Color(0xFFFF3B30),
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                        thumbColor: Colors.white,
                        overlayColor: const Color(0xFFFF3B30).withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: controller.age.value.toDouble(),
                        min: 15,
                        max: 80,
                        onChanged: (val) => controller.age.value = val.round(),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(
      OnboardingController controller, String gender, String emoji, Color accent) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedGender.value == gender;
        return GestureDetector(
          onTap: () => controller.selectGender(gender),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isSelected ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? accent : Colors.white.withValues(alpha: 0.15),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 12)]
                  : null,
            ),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  gender,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStep2(OnboardingController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Body Stats",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          _buildStatSlider(
            "HEIGHT",
            controller.height,
            100,
            220,
            "cm",
            const Color(0xFF007AFF),
          ),
          const SizedBox(height: 24),
          _buildStatSlider(
            "CURRENT WEIGHT",
            controller.currentWeight,
            30,
            200,
            "kg",
            const Color(0xFFFF9500),
          ),
          const SizedBox(height: 24),
          _buildStatSlider(
            "TARGET WEIGHT",
            controller.targetWeight,
            30,
            200,
            "kg",
            const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }

  Widget _buildStatSlider(String label, RxDouble val, double min, double max,
      String unit, Color accentColor) {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    val.value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFFA1A1AA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: accentColor,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                  thumbColor: Colors.white,
                  overlayColor: accentColor.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: val.value,
                  min: min,
                  max: max,
                  onChanged: (v) => val.value = v,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStep3(OnboardingController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hydration Goals",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                "Based on your weight, we recommend ${controller.suggestedWaterIntake}L",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.w500,
                ),
              )),
          const SizedBox(height: 40),
          _buildStatSlider(
            "DAILY TARGET",
            controller.waterTarget,
            1.0,
            6.0,
            "Litres",
            const Color(0xFF007AFF),
          ),
          const SizedBox(height: 24),
          _buildGlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Water Reminders",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Obx(() => Switch(
                          value: controller.waterReminder.value,
                          onChanged: (v) => controller.waterReminder.value = v,
                          activeThumbColor: const Color(0xFF007AFF),
                        )),
                  ],
                ),
                Obx(() => controller.waterReminder.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: Colors.white24, height: 32),
                          const Text(
                            "REMIND ME EVERY",
                            style: TextStyle(
                              color: Color(0xFFA1A1AA),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [1, 2, 3, 4].map((hours) {
                              final isSel = controller.reminderIntervalHours.value == hours;
                              return GestureDetector(
                                onTap: () => controller.reminderIntervalHours.value = hours,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSel ? const Color(0xFF007AFF) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel ? const Color(0xFF007AFF) : Colors.white24,
                                    ),
                                  ),
                                  child: Text(
                                    "${hours}h",
                                    style: TextStyle(
                                      color: isSel ? Colors.white : const Color(0xFFA1A1AA),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(OnboardingController controller) {
    final goals = [
      {'id': 'weight_loss', 'icon': '🏋️', 'title': 'Weight Loss', 'desc': 'Burn fat and get lean'},
      {'id': 'muscle_gain', 'icon': '💪', 'title': 'Muscle Gain', 'desc': 'Build strength and mass'},
      {'id': 'stay_fit', 'icon': '🏃', 'title': 'Stay Fit', 'desc': 'Maintain overall fitness'},
      {'id': 'flexibility', 'icon': '🧘', 'title': 'Flexibility', 'desc': 'Improve mobility and stretch'},
      {'id': 'endurance', 'icon': '⚡', 'title': 'Endurance', 'desc': 'Build stamina and cardio'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Fitness Goal",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select your primary focus",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFA1A1AA),
            ),
          ),
          const SizedBox(height: 32),
          ...goals.map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Obx(() {
                  final isSel = controller.fitnessGoal.value == g['id'];
                  return GestureDetector(
                    onTap: () => controller.selectFitnessGoal(g['id']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: isSel ? 0.12 : 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSel ? const Color(0xFFFF3B30) : Colors.white.withValues(alpha: 0.1),
                          width: isSel ? 2 : 1,
                        ),
                        boxShadow: isSel
                            ? [BoxShadow(color: const Color(0xFFFF3B30).withValues(alpha: 0.3), blurRadius: 12)]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Text(g['icon']!, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g['title']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  g['desc']!,
                                  style: const TextStyle(
                                    color: Color(0xFFA1A1AA),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSel)
                            const Icon(Icons.check_circle, color: Color(0xFFFF3B30)),
                        ],
                      ),
                    ),
                  );
                }),
              )),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
