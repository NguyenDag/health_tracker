import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
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
              // ── Logo Hero ──────────────────────────────────────────────
              const Expanded(flex: 5, child: _LogoHero()),

              const SizedBox(height: 20),

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

// ─── Sub-widget: Logo Hero Panel ───────────────────────────────────────────

class _LogoHero extends StatelessWidget {
  const _LogoHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/logo/banner.png', fit: BoxFit.cover),
            // Bottom gradient overlay for text readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Làm Chủ Sức Khoẻ\nTheo Cách Của Bạn',
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              fontSize: 28,
              height: 1.2,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Giải pháp toàn diện để theo dõi chỉ số cơ thể\nvà cải thiện lối sống mỗi ngày.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMid,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          GradientButton(label: 'Bắt đầu ngay', onPressed: onCreateAccount),
          const SizedBox(height: 12),
          SecondaryButton(label: 'Tôi đã có tài khoản', onPressed: onLogin),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
