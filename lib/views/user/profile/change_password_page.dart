import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Secure Your Account', style: AppTextStyles.h1),
            const SizedBox(height: 12),
            Text(
              'Your password should be at least 8 characters long and include a mix of letters, numbers, and symbols.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            _buildPasswordField('Current Password', 'Enter current password', false),
            const SizedBox(height: 24),
            _buildPasswordField('New Password', 'Minimum 8 characters', false),
            const SizedBox(height: 12),
            _buildStrengthIndicator(),
            const SizedBox(height: 24),
            _buildPasswordField('Confirm New Password', 'Re-enter new password', true),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Update logic
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success, // Using a green similar to the design
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Update Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, String hint, bool isObscured) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.subtitle),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withAlpha(20)), // Subtle purple tint on border
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hint,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary.withAlpha(150), fontSize: 16),
                ),
              ),
              Icon(
                isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 4, color: AppColors.success)),
            const SizedBox(width: 4),
            Expanded(child: Container(height: 4, color: AppColors.success)),
            const SizedBox(width: 4),
            Expanded(child: Container(height: 4, color: Colors.purple.withAlpha(50))),
            const SizedBox(width: 4),
            Expanded(child: Container(height: 4, color: Colors.purple.withAlpha(50))),
          ],
        ),
        const SizedBox(height: 8),
        Text('Strength: Good', style: AppTextStyles.label.copyWith(color: AppColors.success)),
      ],
    );
  }
}
