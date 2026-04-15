import 'package:flutter/material.dart';
import 'package:kavachx/Controller/splash_controller.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

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
              color: const Color(0xFF1C1C22).withOpacity(0.6),
              colorBlendMode: BlendMode.darken,
            )),
          
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E1E24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3B30).withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 64,
                    color: Color(0xFFFF3B30),
                  ),
                ),
                const SizedBox(height: 24),

                // App Brand Name
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                    children: [
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.0,
                  ),
                ),
                const SizedBox(height: 48),

                // Progress Indicator
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF3B30)),
                    strokeWidth: 2.5,
                  ),
                ),
              ],
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
                style: TextStyle(
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