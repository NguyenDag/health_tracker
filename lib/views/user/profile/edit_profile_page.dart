import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // Save logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save),
                SizedBox(width: 8),
                Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildProfileAvatar(),
            const SizedBox(height: 32),
            _buildInputField('Full Name', 'Alex Richardson'),
            const SizedBox(height: 24),
            _buildInputField('Date of Birth', '05/12/1992', suffixIcon: Icons.calendar_today_outlined),
            const SizedBox(height: 24),
            _buildInputField('Gender', 'Male', suffixIcon: Icons.keyboard_arrow_down),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildInputField('Height (cm)', '182')),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField('Weight (kg)', '78')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLight, width: 2),
              ),
              child: const CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, size: 48, color: AppColors.primary),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.lightBlue[300],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            )
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('Change Photo', style: AppTextStyles.label.copyWith(color: Colors.green[800])),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, String value, {IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withAlpha(30)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontSize: 16),
                ),
              ),
              if (suffixIcon != null) Icon(suffixIcon, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}
