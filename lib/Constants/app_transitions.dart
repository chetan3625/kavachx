import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Industry-quality page transitions for KavachX.
/// Use [AppTransitions.to()] as a drop-in replacement for [Get.to()].
class AppTransitions {
  AppTransitions._();

  // ── Durations ──────────────────────────────────────────────────────────────
  static const Duration _fast = Duration(milliseconds: 280);
  static const Duration _medium = Duration(milliseconds: 380);
  static const Duration _slow = Duration(milliseconds: 500);

  // ── Curves ─────────────────────────────────────────────────────────────────
  static const Curve _standard = Curves.easeInOutCubic;
  static const Curve _decelerate = Curves.easeOutCubic;
  static const Curve _spring = Curves.easeOutBack;

  // ═══════════════════════════════════════════════════════════════════════════
  //  Get.to() helpers — wrap your page builder with the right transition
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fade + slide up — for dashboards / main screens after auth.
  static Future<T?> fadeSlide<T>(Widget Function() page,
      {String? routeName}) async {
    return Get.to<T>(page,
        transition: Transition.fadeIn,
        duration: _medium,
        curve: _decelerate,
        routeName: routeName);
  }

  /// Slide from right — standard iOS-style push navigation.
  static Future<T?> slideRight<T>(Widget Function() page,
      {String? routeName}) async {
    return Get.to<T>(page,
        transition: Transition.rightToLeft,
        duration: _fast,
        curve: _decelerate,
        routeName: routeName);
  }

  /// Slide from bottom — sheet-like for onboarding, profiles, detail pages.
  static Future<T?> slideUp<T>(Widget Function() page,
      {String? routeName}) async {
    return Get.to<T>(page,
        transition: Transition.downToUp,
        duration: _medium,
        curve: _decelerate,
        routeName: routeName);
  }

  /// Scale + fade — for QR display, modals, focused detail screens.
  static Future<T?> scaleFade<T>(Widget Function() page,
      {String? routeName}) async {
    return Get.to<T>(page,
        transition: Transition.zoom,
        duration: _medium,
        curve: _spring,
        routeName: routeName);
  }

  /// Hero fade — elegant brand reveal (splash -> role-selection).
  static Future<T?> heroFade<T>(Widget Function() page,
      {String? routeName}) async {
    return Get.to<T>(page,
        transition: Transition.fade,
        duration: _slow,
        curve: _standard,
        routeName: routeName);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  GetPage transition builders — use directly in GetMaterialApp.getPages
  // ═══════════════════════════════════════════════════════════════════════════

  /// For dashboard routes navigated via [Get.offAllNamed] / [Get.offNamed].
  static Transition get fadeSlideTransition => Transition.fadeIn;
  static Duration get dashboardDuration => _medium;

  /// For role-selection brand reveal.
  static Transition get heroFadeTransition => Transition.fade;
  static Duration get heroFadeDuration => _slow;

  /// For onboarding routes.
  static Transition get slideUpTransition => Transition.downToUp;
  static Duration get onboardingDuration => _medium;

  // ═══════════════════════════════════════════════════════════════════════════
  //  Custom animated route builder (for fully custom animations)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Creates a custom [PageRouteBuilder] with a combined fade + upward slide.
  static PageRouteBuilder<T> buildFadeSlideRoute<T>({
    required Widget page,
    Duration duration = _medium,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: _decelerate);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: _decelerate));

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  /// Creates a custom [PageRouteBuilder] with a slide-from-right transition.
  static PageRouteBuilder<T> buildSlideRightRoute<T>({
    required Widget page,
    Duration duration = _fast,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1.0, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: _decelerate));

        final outSlide = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.25, 0),
        ).animate(CurvedAnimation(parent: secondaryAnimation, curve: _decelerate));

        return SlideTransition(
          position: outSlide,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  /// Creates a slide-up (bottom sheet style) [PageRouteBuilder].
  static PageRouteBuilder<T> buildSlideUpRoute<T>({
    required Widget page,
    Duration duration = _medium,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: _decelerate));

        final fade = CurvedAnimation(parent: animation, curve: _decelerate);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  /// Scale + fade — for QR screens, modals, and focused views.
  static PageRouteBuilder<T> buildScaleFadeRoute<T>({
    required Widget page,
    Duration duration = _medium,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scale = Tween<double>(begin: 0.88, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: _spring),
        );
        final fade = CurvedAnimation(parent: animation, curve: _decelerate);

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );
  }
}
