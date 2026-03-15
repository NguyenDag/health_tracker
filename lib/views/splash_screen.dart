import 'package:flutter/material.dart';
import 'package:health_tracker/views/widgets/shared_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:math' as math;

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/router/app_router.dart';
import 'auth/onboarding_screen.dart';
import 'user/main/main_layout_page.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SPLASH SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeIn;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    Timer(const Duration(seconds: 3), () async {
      _spinCtrl.stop();
      if (mounted) setState(() => _isLoading = false);
      
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      // ── Check for an existing Supabase session ──────────────
      final authViewModel = context.read<AuthViewModel>();
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        // Load user profile before navigating
        await authViewModel.loadCurrentUser();
        if (mounted) replaceWithFade(context, const MainLayoutPage());
      } else {
        if (mounted) replaceWithFade(context, const OnboardingScreen());
      }
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // ── Spinning / pulsing icon ─────────────────────────
                _SpinningIcon(
                  spinCtrl: _spinCtrl,
                  pulseCtrl: _pulseCtrl,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 32),
                const Text('HealthTracker', style: AppTextStyles.heading1),
                const SizedBox(height: 10),
                const Text(
                  'Monitor your vitals effortlessly',
                  style: TextStyle(fontSize: 15, color: AppColors.textGrey),
                ),

                const Spacer(flex: 3),

                // ── Loading indicator ───────────────────────────────
                _LoadingIndicator(visible: _isLoading),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widget: spinning + pulsing icon ─────────────────────────────────────

class _SpinningIcon extends StatelessWidget {
  const _SpinningIcon({
    required this.spinCtrl,
    required this.pulseCtrl,
    required this.isLoading,
  });

  final AnimationController spinCtrl;
  final AnimationController pulseCtrl;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([spinCtrl, pulseCtrl]),
      builder: (_, child) => Transform.scale(
        scale: isLoading ? 1.0 + pulseCtrl.value * 0.04 : 1.0,
        child: Transform.rotate(
          angle: isLoading ? spinCtrl.value * 2 * math.pi : 0.0,
          child: child,
        ),
      ),
      child: const AppIconWidget(),
    );
  }
}

// ─── Sub-widget: loading indicator ───────────────────────────────────────────

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('ĐANG TẢI DỮ LIỆU SỨC KHOẺ...', style: AppTextStyles.hint),
        ],
      ),
    );
  }
}
