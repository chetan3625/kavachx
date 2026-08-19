import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kavachx/Controller/splash_controller.dart';
import 'package:get/get.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Ensure SplashController is registered
    if (!Get.isRegistered<SplashController>()) {
      Get.put(SplashController());
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12), // Dark modern gym theme
      body: Stack(
        children: [
          // Background subtle gradient glow
          Positioned.fill(
            child: Image.asset(
              'asset/app_backgrounds/splas_background.jpg',
              fit: BoxFit.cover,
              color: const Color(0xFF1C1C22).withValues(alpha: 0.6),
              colorBlendMode: BlendMode.darken,
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo Icon with Pulse Glow
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E1E24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFF3B30,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 35,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              size: 68,
                              color: Color(0xFFFF3B30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // App Brand Name
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.outfit(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                            ),
                            children: const [
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

                        // Tagline
                        Text(
                          'GYM MANAGEMENT & FITNESS',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3.5,
                          ),
                        ),
                        const SizedBox(height: 52),

                        // Progress Indicator
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF3B30),
                            ),
                            strokeWidth: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer version tag
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v1.0.0',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}