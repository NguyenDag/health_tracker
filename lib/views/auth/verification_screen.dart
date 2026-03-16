import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../widgets/shared_widgets.dart';
import 'login_page.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// VERIFICATION SCREEN
// Shown after registration. Supabase sends a confirmation link by email.
// ═══════════════════════════════════════════════════════════════════════════════

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: const [
                  AppBackButton(),
                  Spacer(),
                  Text('Xác nhận email', style: AppTextStyles.heading3),
                  Spacer(flex: 1),
                  SizedBox(width: 32),
                ],
              ),

              const Spacer(flex: 2),

              // ── Icon ─────────────────────────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FBF8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Title ─────────────────────────────────────────────
              const Center(
                child: Text('Xác nhận email', style: AppTextStyles.heading1),
              ),

              const SizedBox(height: 16),

              // ── Body text ─────────────────────────────────────────
              const Center(
                child: Text(
                  'Chúng tôi đã gửi một email xác nhận đến địa chỉ email của bạn.\n\n'
                  'Vui lòng kiểm tra hộp thư và nhấn vào liên kết xác nhận để kích hoạt tài khoản.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
              ),

              const SizedBox(height: 24),

              // ── Tip box ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FBF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Nếu không thấy email, hãy kiểm tra thư mục Spam hoặc Thư rác.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMid),
                    ),
                  ),
                ]),
              ),

              const Spacer(flex: 3),

              // ── Go to Login ───────────────────────────────────────
              GradientButton(
                label: 'Đến trang đăng nhập',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const LoginScreen(),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
