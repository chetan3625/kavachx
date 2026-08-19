import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavachx/Constants/app_transitions.dart';
import 'package:kavachx/Constants/user_role.dart';
import 'package:kavachx/VIew/auth_view.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

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
              color: const Color(0xFF0F0F12).withValues(alpha: 0.75),
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
                    text: TextSpan(
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Welcome to ',
                          style: TextStyle(color: Colors.white),
                        ),
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
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFFA1A1AA),
                    ),
                  ),

                  const Spacer(),

                  // Gym Owner Card
                  _RoleCard(
                    title: 'Gym Owner',
                    subtitle:
                        'Manage members, slots, attendance & notifications',
                    icon: Icons.admin_panel_settings_rounded,
                    onTap: () {
                      AppTransitions.slideRight(
                        () => const AuthView(role: UserRole.gymOwner),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Gym Member Card
                  _RoleCard(
                    title: 'Gym Member',
                    subtitle: 'Book slots, check-in, view plans & benefits',
                    icon: Icons.fitness_center_rounded,
                    onTap: () {
                      AppTransitions.slideRight(
                        () => const AuthView(role: UserRole.gymMember),
                      );
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

class _RoleCard extends StatefulWidget {
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
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C22).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color.lerp(
                    const Color(0xFF2A2A34),
                    const Color(0xFFFF3B30),
                    _glowAnim.value * 0.6,
                  )!,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3B30)
                        .withValues(alpha: _glowAnim.value * 0.15),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
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
                          widget.title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFFA1A1AA),
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
        },
      ),
    );
  }
}