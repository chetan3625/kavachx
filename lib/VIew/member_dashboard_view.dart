import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:kavachx/Controller/member_dashboard_controller.dart';
import 'package:kavachx/Model/exercise_model.dart';

import 'package:kavachx/VIew/member_subscription_view.dart';
import 'package:kavachx/VIew/member_profile_view.dart';
import 'package:kavachx/VIew/member_attendance_history_view.dart';
import 'package:kavachx/VIew/member_notifications_view.dart';

class MemberDashboardView extends StatelessWidget {
  const MemberDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MemberDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // Ambient Neon Glow Background Blobs
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF3B30).withValues(alpha: 0.20),
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                ),
              ),
            ),

            // Background Image
            Positioned.fill(
              child: Image.asset(
                'asset/app_backgrounds/authscreen.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                color: const Color(0xFF0F0F12).withValues(alpha: 0.80),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            SafeArea(
              child: Obx(() {
                switch (controller.selectedBottomIndex.value) {
                  case 0:
                    return _buildHomeTab(context, controller);
                  case 1:
                    return const MemberAttendanceHistoryView();
                  case 2:
                    return const MemberSubscriptionView();
                  case 3:
                    return const MemberNotificationsView();
                  case 4:
                    return const MemberProfileView();
                  default:
                    return _buildHomeTab(context, controller);
                }
              }),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Obx(
        () => _GlassContainer(
          borderRadius: 0,
          opacity: 0.1,
          borderOpacity: 0.1,
          blur: 15,
          padding: EdgeInsets.zero,
          child: BottomNavigationBar(
            currentIndex: controller.selectedBottomIndex.value,
            onTap: (index) => controller.selectedBottomIndex.value = index,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFFFF3B30),
            unselectedItemColor: const Color(0xFFA1A1AA),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_rounded),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_membership_rounded),
                label: 'Plans',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_rounded),
                label: 'Alerts',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- MAIN DASHBOARD TAB ---
  Widget _buildHomeTab(
    BuildContext context,
    MemberDashboardController controller,
  ) {
    return SingleChildScrollView(
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
                  children: [
                    Obx(
                      () => Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Welcome ',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: controller.userFirstName.value,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF3B30),
                              ),
                            ),
                            const TextSpan(
                              text: ' 👋',
                              style: TextStyle(fontSize: 22),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => Text(
                        'Target Today: ${controller.todayTargetPart.value}',
                        style: const TextStyle(
                          color: Color(0xFFFF3B30),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 🔥 Compact Streak Badge
              Obx(
                () => _GlassContainer(
                  borderRadius: 10,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  opacity: 0.15,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 3),
                      Text(
                        '${controller.currentStreakDays.value}d',
                        style: const TextStyle(
                          color: Color(0xFFFF9500),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- 1. WEEKLY ATTENDANCE / ACTIVITY TRACKER (Only rendered if associated with gym) ---
          Obx(() {
            if (!controller.isAssociatedWithGym.value) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                _GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WEEKLY GYM ACTIVITY',
                        style: TextStyle(
                          color: Color(0xFFFF3B30),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        final activity = controller.weeklyActivity;
                        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final now = DateTime.now();
                        final todayIndex = (now.weekday - 1) % 7;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (index) {
                            final active = index < activity.length
                                ? activity[index]
                                : false;
                            return _DayBubble(
                              day: days[index],
                              active: active,
                              isToday: index == todayIndex,
                            );
                          }),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }),

          // --- 2. GLASSMORPHIC CHECK IN / CHECK OUT SLIDER (Only rendered if associated with gym) ---
          Obx(() {
            if (!controller.isAssociatedWithGym.value) {
              return const SizedBox.shrink();
            }

            final isCheckedIn = controller.isCheckedIn.value;
            final hasCompleted = controller.hasCompletedTodayAttendance.value;

            Widget sliderWidget;

            if (hasCompleted && !isCheckedIn) {
              sliderWidget = ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF34C759).withValues(alpha: 0.40),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF34C759),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "TODAY'S ATTENDANCE COMPLETED",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              final themeColor = isCheckedIn
                  ? const Color(0xFFFF3B30)
                  : const Color(0xFF34C759);

              sliderWidget = ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.40),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SlideAction(
                      key: ValueKey(isCheckedIn),
                      reversed: isCheckedIn,
                      onSubmit: () {
                        controller.toggleCheckIn(!isCheckedIn);
                        return null;
                      },
                      alignment: Alignment.centerRight,
                      text: isCheckedIn
                          ? '◀  SLIDE TO CHECK OUT      '
                          : 'SLIDE TO CHECK IN  ▶      ',
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      outerColor: Colors.transparent,
                      innerColor: themeColor,
                      sliderButtonIcon: Icon(
                        isCheckedIn
                            ? Icons.logout_rounded
                            : Icons.login_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      borderRadius: 20,
                      height: 56,
                      elevation: 0,
                    ),
                  ),
                ),
              );
            }

            return Column(children: [sliderWidget, const SizedBox(height: 24)]);
          }),

          // --- 3. WATER HYDRATION & BODY WEIGHT METRICS ---
          Row(
            children: [
              // Water Tracker Glass Widget
              Expanded(
                child: Obx(
                  () => _GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.water_drop_rounded,
                              color: Color(0xFF007AFF),
                              size: 20,
                            ),
                            Text(
                              '${controller.currentWaterLitres.value.toStringAsFixed(1)}L / ${controller.targetWaterLitres.value.toStringAsFixed(1)}L',
                              style: const TextStyle(
                                color: Color(0xFF007AFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hydration Target',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${controller.waterGlasses.value} Glasses',
                              style: const TextStyle(
                                color: Color(0xFFA1A1AA),
                                fontSize: 11,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => controller.addGlassOfWater(),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF007AFF,
                                  ).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Weight Goal Glass Widget
              Expanded(
                child: Obx(
                  () => _GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.monitor_weight_rounded,
                              color: Color(0xFF34C759),
                              size: 20,
                            ),
                            Text(
                              'Goal: ${controller.targetWeightKg.value.toStringAsFixed(0)} kg',
                              style: const TextStyle(
                                color: Color(0xFF34C759),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Current Weight',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${controller.currentWeightKg.value.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: Color(0xFFA1A1AA),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // TODAY'S WORKOUT PROGRESS STATS
          const Text(
            "TODAY'S WORKOUT SUMMARY",
            style: TextStyle(
              color: Color(0xFFFF3B30),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          Obx(() {
            final completed = controller.completedSetsCount;
            final remaining = controller.remainingSetsCount;
            final total = controller.totalSetsCount;
            final progress = controller.workoutProgressRatio;

            return _GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatColumn(
                        title: 'Done Sets',
                        value: '$completed',
                        color: const Color(0xFF34C759),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      _StatColumn(
                        title: 'Remaining',
                        value: '$remaining',
                        color: const Color(0xFFFF9500),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      _StatColumn(
                        title: 'Total Sets',
                        value: '$total',
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.10),
                      color: const Color(0xFFFF3B30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(progress * 100).toInt()}% Completed',
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // TODAY'S EXERCISES LIST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'EXERCISE ROUTINE',
                style: TextStyle(
                  color: Color(0xFFFF3B30),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                ),
              ),
              InkWell(
                onTap: () => _showAddExerciseBottomSheet(context, controller),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.add, color: Color(0xFFFF3B30), size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Add Exercise',
                        style: TextStyle(
                          color: Color(0xFFFF3B30),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Obx(() {
            if (controller.todayExercises.isEmpty) {
              return _GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(
                        Icons.fitness_center_outlined,
                        color: Color(0xFFA1A1AA),
                        size: 36,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No Exercises Planned For Today',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap "+ Add Exercise" to start building your routine!',
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
              itemCount: controller.todayExercises.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final exercise = controller.todayExercises[index];
                return _ExerciseCard(
                  exercise: exercise,
                  onAddSet: () => controller.incrementSet(exercise.id),
                  onDelete: () => controller.removeExercise(exercise.id),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

// Reusable Glassmorphism Wrapper
class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double opacity;
  final double borderOpacity;
  final double blur;

  const _GlassContainer({
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.opacity = 0.08,
    this.borderOpacity = 0.15,
    this.blur = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
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

// Day Bubble Helper for Weekly Tracker
class _DayBubble extends StatelessWidget {
  final String day;
  final bool active;
  final bool isToday;

  const _DayBubble({
    required this.day,
    required this.active,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? const Color(0xFF34C759)
                : isToday
                ? const Color(0xFFFF3B30)
                : Colors.white.withValues(alpha: 0.08),
            border: isToday
                ? Border.all(color: Colors.white, width: 1.5)
                : null,
          ),
          child: Center(
            child: Icon(
              active ? Icons.check_rounded : Icons.circle,
              color: active ? Colors.white : Colors.transparent,
              size: 16,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            color: isToday ? Colors.white : const Color(0xFFA1A1AA),
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// Stat Column Helper
class _StatColumn extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatColumn({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
        ),
      ],
    );
  }
}

// Glassmorphic Interactive Exercise Item Card
class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onAddSet;
  final VoidCallback onDelete;

  const _ExerciseCard({
    required this.exercise,
    required this.onAddSet,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      padding: const EdgeInsets.all(14),
      borderOpacity: exercise.isCompleted ? 0.35 : 0.12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: exercise.isCompleted
                  ? const Color(0xFF34C759).withValues(alpha: 0.20)
                  : const Color(0xFFFF3B30).withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              exercise.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.fitness_center_rounded,
              color: exercise.isCompleted
                  ? const Color(0xFF34C759)
                  : const Color(0xFFFF3B30),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${exercise.muscleGroup}  •  ${exercise.weightInKg.toStringAsFixed(0)}kg  •  ${exercise.repsPerSet} reps  •  ${exercise.durationMinutes}m',
                  style: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFFF3B30),
              size: 20,
            ),
            onPressed: onDelete,
            tooltip: 'Remove exercise',
          ),
          InkWell(
            onTap: exercise.isCompleted ? null : onAddSet,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: exercise.isCompleted
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFFF3B30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${exercise.completedSets}/${exercise.totalSets} SETS',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showAddExerciseBottomSheet(
  BuildContext context,
  MemberDashboardController controller,
) {
  final nameCtrl = TextEditingController();
  final muscleCtrl = TextEditingController(text: 'Chest');
  final weightCtrl = TextEditingController(text: '20');
  final repsCtrl = TextEditingController(text: '12');
  final setsCtrl = TextEditingController(text: '4');
  final durationCtrl = TextEditingController(text: '15');
  final notesCtrl = TextEditingController();

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  'Add Exercise Routine',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildModalField(
              controller: nameCtrl,
              label: 'Exercise Name',
              hint: 'e.g. Dumbbell Bicep Curl',
            ),
            const SizedBox(height: 10),
            _buildModalField(
              controller: muscleCtrl,
              label: 'Muscle Group',
              hint: 'e.g. Biceps, Chest, Legs',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildModalField(
                    controller: weightCtrl,
                    label: 'Weight (kg)',
                    hint: '20',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildModalField(
                    controller: repsCtrl,
                    label: 'Reps / Set',
                    hint: '12',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildModalField(
                    controller: setsCtrl,
                    label: 'Total Sets',
                    hint: '4',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildModalField(
                    controller: durationCtrl,
                    label: 'Duration (min)',
                    hint: '15',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildModalField(
              controller: notesCtrl,
              label: 'Notes (Optional)',
              hint: 'e.g. Focus on form',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final muscle = muscleCtrl.text.trim();
                  if (name.isEmpty || muscle.isEmpty) return;

                  controller.addNewExercise(
                    name: name,
                    muscleGroup: muscle,
                    weightInKg: double.tryParse(weightCtrl.text.trim()) ?? 0,
                    repsPerSet: int.tryParse(repsCtrl.text.trim()) ?? 10,
                    totalSets: int.tryParse(setsCtrl.text.trim()) ?? 4,
                    durationMinutes:
                        int.tryParse(durationCtrl.text.trim()) ?? 15,
                    notes: notesCtrl.text.trim(),
                  );
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Exercise',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

Widget _buildModalField({
  required TextEditingController controller,
  required String label,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
      ),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF71717A)),
          filled: true,
          fillColor: const Color(0xFF2C2C35),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ],
  );
}
