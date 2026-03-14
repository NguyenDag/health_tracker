import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../app_painters.dart';
import '../widgets/shared_widgets.dart';
import 'login_page.dart';
import 'registration_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ONBOARDING SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Illustration ──────────────────────────────────────────────
              const Expanded(flex: 5, child: _SceneryIllustration()),

              const SizedBox(height: 28),

              // ── Animated content area ─────────────────────────────────────
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: _OnboardingContent(
                    onCreateAccount: () =>
                        pushScreen(context, const RegistrationScreen()),
                    onLogin: () => pushScreen(context, const LoginScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widget: scenery illustration panel ───────────────────────────────────

class _SceneryIllustration extends StatelessWidget {
  const _SceneryIllustration();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Sky gradient
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.scenery),
          ),
          // Mountains + trees + road
          const CustomPaint(painter: SceneryPainter()),
          // Runner character
          const Center(
            child: CustomPaint(size: Size(130, 200), painter: RunnerPainter()),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widget: text headline + action buttons ───────────────────────────────

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({
    required this.onCreateAccount,
    required this.onLogin,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Text(
            'Theo dõi hành trình\nsức khoẻ của bạn',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.25,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Theo dõi huyết áp, đường huyết,\ncân nặng và SpO2 tất cả trong một nơi.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 28),

          GradientButton(
            label: 'Tạo tài khoản mới',
            onPressed: onCreateAccount,
          ),
          const SizedBox(height: 12),
          SecondaryButton(label: 'Đăng nhập', onPressed: onLogin),
          const SizedBox(height: 14),

          TextButton(
            onPressed: () {},
            child: const Text(
              'Tiếp tục với tư cách khách',
              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
