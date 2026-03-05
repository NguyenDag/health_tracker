import 'package:flutter/material.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../widgets/shared_widgets.dart';
import 'login_page.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// REGISTRATION SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: '25');
  final _weightCtrl = TextEditingController(text: '70');
  final _heightCtrl = TextEditingController(text: '175');
  String _gender = 'Male';

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _phoneCtrl,
      _ageCtrl,
      _weightCtrl,
      _heightCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top navigation bar ───────────────────────────────────────
            const _RegistrationAppBar(),

            // ── Step progress indicator ──────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ProgressStepHeader(
                step: 1,
                total: 3,
                label: 'Health Profile',
              ),
            ),

            const SizedBox(height: 24),

            // ── Scrollable form body ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _RegistrationHeadline(),
                    const SizedBox(height: 28),

                    // Full name
                    const FormFieldLabel('Full Name'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Sarah Jenkins',
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Phone
                    const FormFieldLabel('Phone Number'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '+1 (555) 000-0000',
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Age + Gender row
                    _AgeGenderRow(
                      ageCtrl: _ageCtrl,
                      gender: _gender,
                      onGenderChanged: (v) => setState(() => _gender = v!),
                    ),
                    const SizedBox(height: 18),

                    // Weight + Height row
                    _WeightHeightRow(
                      weightCtrl: _weightCtrl,
                      heightCtrl: _heightCtrl,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Continue button ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GradientButton(
                label: 'Register',
                onPressed: () {
                  () => pushScreen(context, const LoginScreen());
                },
              ),
            ),
            /*Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: GradientButton(
              label: 'Continue',
              onPressed: () {},
              trailing: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white, size: 18,
              ),
            ),
          ),*/
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widget: app bar with back + title ────────────────────────────────────

class _RegistrationAppBar extends StatelessWidget {
  const _RegistrationAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: const [
          AppBackButton(),
          Spacer(),
          Text('Registration', style: AppTextStyles.heading3),
          Spacer(),
          SizedBox(width: 32), // balance the back button
        ],
      ),
    );
  }
}

// ─── Sub-widget: title + subtitle ────────────────────────────────────────────

class _RegistrationHeadline extends StatelessWidget {
  const _RegistrationHeadline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Create your profile', style: AppTextStyles.heading2),
        SizedBox(height: 6),
        Text(
          "Let's gather some basic health metrics to\npersonalize your AI wellness journey.",
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}

// ─── Sub-widget: Age + Gender side-by-side ───────────────────────────────────

class _AgeGenderRow extends StatelessWidget {
  const _AgeGenderRow({
    required this.ageCtrl,
    required this.gender,
    required this.onGenderChanged,
  });

  final TextEditingController ageCtrl;
  final String gender;
  final ValueChanged<String?> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormFieldLabel('Age'),
              const SizedBox(height: 8),
              TextField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormFieldLabel('Gender'),
              const SizedBox(height: 8),
              GenderDropdown(value: gender, onChanged: onGenderChanged),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Sub-widget: Weight + Height side-by-side ────────────────────────────────

class _WeightHeightRow extends StatelessWidget {
  const _WeightHeightRow({required this.weightCtrl, required this.heightCtrl});

  final TextEditingController weightCtrl;
  final TextEditingController heightCtrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormFieldLabel('Weight (kg)'),
              const SizedBox(height: 8),
              UnitTextField(controller: weightCtrl, unit: 'KG'),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormFieldLabel('Height (cm)'),
              const SizedBox(height: 8),
              UnitTextField(controller: heightCtrl, unit: 'CM'),
            ],
          ),
        ),
      ],
    );
  }
}
