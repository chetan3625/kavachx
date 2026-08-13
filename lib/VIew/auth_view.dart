import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kavachx/Constants/user_role.dart';
import 'package:kavachx/Controller/auth_controller.dart';

class AuthView extends StatelessWidget {
  final UserRole role;

  const AuthView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // Instantiate controller with the passed role
    final AuthController controller = Get.put(
      AuthController(role: role),
      tag: role.name,
    );

    final String roleDisplayName =
        role == UserRole.gymOwner ? 'Gym Owner' : 'Gym Member';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // 1. Fullscreen Background Image
            Positioned.fill(
              child: Image.asset(
                'asset/app_backgrounds/authscreen.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                color: const Color(0xFF0F0F12).withValues(alpha: 0.80),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // 2. Foreground Form Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Role Badge Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFF3B30), width: 1),
                      ),
                      child: Text(
                        'User is ${role.name}',
                        style: const TextStyle(
                          color: Color(0xFFFF3B30),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Continue as $roleDisplayName',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your details to access your account',
                      style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
                    ),

                    const SizedBox(height: 24),

                    // Tab Switcher (Login / Register)
                    Obx(() => Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C22).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2A2A34), width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.selectedTab.value = 0,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: controller.selectedTab.value == 0
                                          ? const Color(0xFFFF3B30)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Login',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: controller.selectedTab.value == 0
                                              ? Colors.white
                                              : const Color(0xFFA1A1AA),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => controller.selectedTab.value = 1,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: controller.selectedTab.value == 1
                                          ? const Color(0xFFFF3B30)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Register',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: controller.selectedTab.value == 1
                                              ? Colors.white
                                              : const Color(0xFFA1A1AA),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 28),

                    // Form Fields
                    Obx(() {
                      final isRegister = controller.selectedTab.value == 1;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isRegister) ...[
                            // User Full Name
                            TextField(
                              controller: controller.nameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Full Name',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // User Email
                          TextField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Email Address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (isRegister) ...[
                            // User Phone Number
                            TextField(
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone_android_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Dynamic Gym Details Section (Owner Only)
                            if (role == UserRole.gymOwner) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'GYM DETAILS',
                                  style: TextStyle(
                                    color: Color(0xFFFF3B30),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              TextField(
                                controller: controller.gymNameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Gym Name',
                                  prefixIcon: Icon(Icons.fitness_center_rounded),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: controller.gymPhoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Gym Contact Phone',
                                  prefixIcon: Icon(Icons.contact_phone_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: controller.gymAddressController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Gym Address / Location',
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],

                          // Password
                          TextField(
                            controller: controller.passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline_rounded),
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 32),

                    // Submit Button with Loading State
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.submitAuth,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  controller.selectedTab.value == 0
                                      ? 'LOGIN'
                                      : 'REGISTER',
                                ),
                        )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}