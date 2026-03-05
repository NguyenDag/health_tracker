import 'package:flutter/material.dart';
import 'dart:async';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../widgets/shared_widgets.dart';
import 'registration_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// VERIFICATION SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _ctrls = List.generate(4, (_) => TextEditingController());
  final List<FocusNode>             _nodes = List.generate(4, (_) => FocusNode());
  int _seconds = 90;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) { t.cancel(); return; }
      setState(() => _seconds--);
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) FocusScope.of(context).requestFocus(_nodes[index + 1]);
    if (value.isEmpty  && index > 0) FocusScope.of(context).requestFocus(_nodes[index - 1]);
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),
            const AppBackButton(),

            const Spacer(flex: 2),

            // ── Icon + headline ────────────────────────────────────────
            const _VerificationHeader(),

            const SizedBox(height: 40),

            // ── OTP input row ──────────────────────────────────────────
            _OtpInputRow(
              controllers: _ctrls,
              focusNodes: _nodes,
              onChanged: _onOtpChanged,
            ),

            const SizedBox(height: 32),

            // ── Countdown timer ────────────────────────────────────────
            _CountdownTimer(seconds: _seconds),

            const SizedBox(height: 16),

            // ── Resend link ────────────────────────────────────────────
            _ResendLink(
              enabled: _seconds == 0,
              onTap: () { setState(() => _seconds = 90); _startTimer(); },
            ),

            const Spacer(flex: 3),

            // ── Verify button ──────────────────────────────────────────
            GradientButton(
              label: 'Verify',
              onPressed: () => pushScreen(context, const RegistrationScreen()),
            ),

            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}

// ─── Sub-widget: email icon + title + subtitle ────────────────────────────────

class _VerificationHeader extends StatelessWidget {
  const _VerificationHeader();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Center(
        child: Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFE8FBF8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.primary, size: 36,
          ),
        ),
      ),
      const SizedBox(height: 28),
      const Center(
        child: Text('Enter Code', style: AppTextStyles.heading1),
      ),
      const SizedBox(height: 12),
      const Center(
        child: Text(
          "We've sent a 4-digit code to your mobile\nnumber ending in ••89.",
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
      ),
    ]);
  }
}

// ─── Sub-widget: row of 4 OTP boxes ──────────────────────────────────────────

class _OtpInputRow extends StatelessWidget {
  const _OtpInputRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (i) => OtpBox(
        controller: controllers[i],
        focusNode: focusNodes[i],
        onChanged: (v) => onChanged(i, v),
      )),
    );
  }
}

// ─── Sub-widget: countdown timer display ─────────────────────────────────────

class _CountdownTimer extends StatelessWidget {
  const _CountdownTimer({required this.seconds});
  final int seconds;

  String get _display {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          _display,
          style: const TextStyle(
            fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600,
          ),
        ),
      ]),
    );
  }
}

// ─── Sub-widget: resend code text button ─────────────────────────────────────

class _ResendLink extends StatelessWidget {
  const _ResendLink({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: enabled ? onTap : null,
        child: Text(
          'Resend Code',
          style: TextStyle(
            fontSize: 14,
            color: enabled ? AppColors.primary : AppColors.textHint,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
