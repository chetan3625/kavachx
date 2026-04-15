import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Constants/user_role.dart';
import 'package:kavachx/VIew/auth_view.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Stack(
        children: [
          // Background Image extending full screen (behind status bar & bottom area)
          Positioned.fill(
            child: Image.asset(
              'asset/app_backgrounds/role_selection.jpg',
              fit: BoxFit.cover,
              color: const Color(0xFF0F0F12).withOpacity(0.75),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // Foreground Content protected by SafeArea
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // Header
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(text: 'Welcome to '),
                        TextSpan(
                          text: 'KAVACH',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'X',
                          style: TextStyle(color: Color(0xFFFF3B30)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you want to continue',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const Spacer(),

                  // Gym Owner Card
                  _RoleCard(
                    title: 'Gym Owner',
                    subtitle:
                        'Manage members, slots, attendance & notifications',
                    icon: Icons.admin_panel_settings_rounded,
                    onTap: () {
                      Get.to(() => const AuthView(role: UserRole.gymOwner));
                    },
                  ),

                  const SizedBox(height: 16),

                  // Gym Member Card
                  _RoleCard(
                    title: 'Gym Member',
                    subtitle: 'Book slots, check-in, view plans & benefits',
                    icon: Icons.fitness_center_rounded,
                    onTap: () {
                      Get.to(() => const AuthView(role: UserRole.gymMember));
                    },
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C22).withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A34), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFF3B30),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA1A1AA),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFFA1A1AA),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}