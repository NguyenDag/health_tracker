import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../thresholds/admin_thresholds_page.dart';

class _ThresholdRow {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _ThresholdRow({required this.icon, required this.color, required this.label, required this.value});
}

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monday, 12 Oct', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 4),
          Text('Overview', style: AppTextStyles.h1.copyWith(fontSize: 28)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Users',
                  value: '1,245',
                  percentage: '+5%',
                  icon: Icons.people,
                  color: AppColors.primary,
                  bgColor: AppColors.primaryLight.withAlpha(50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'Active Today',
                  value: '856',
                  percentage: '+12%',
                  icon: Icons.show_chart,
                  color: Colors.blue,
                  bgColor: AppColors.spo2Bg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricBanner(
            title: 'New Signups',
            value: '45',
            percentage: '+8%',
            icon: Icons.person_add,
            color: Colors.purple,
            bgColor: AppColors.bloodSugarBg,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Threshold Config', style: AppTextStyles.h2),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminThresholdsPage()),
                ),
                child: Text(
                  'Config',
                  style: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildThresholdSummaryCard(context),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String percentage,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    percentage,
                    style: AppTextStyles.label.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.h2.copyWith(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricBanner({
    required String title,
    required String value,
    required String percentage,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Card(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    percentage,
                    style: AppTextStyles.label.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.h2.copyWith(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdSummaryCard(BuildContext context) {
    final rows = [
      _ThresholdRow(
        icon: Icons.favorite_border,
        color: AppColors.error,
        label: 'Blood Pressure',
        value:
            '90–120 / 60–80 mmHg',
      ),
      _ThresholdRow(
        icon: Icons.water_drop_outlined,
        color: Colors.orange,
        label: 'Blood Glucose',
        value:
            '70–100 mg/dL',
      ),
      _ThresholdRow(
        icon: Icons.air,
        color: AppColors.success,
        label: 'Oxygen (SpO2)',
        value:
            '95–100 %',
      ),
      _ThresholdRow(
        icon: Icons.monitor_weight_outlined,
        color: Colors.deepPurple,
        label: 'Target BMI',
        value:
            '18.5–24.9',
      ),
    ];

    return Card(
      color: Colors.white,
      shadowColor: Colors.black.withAlpha(13),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: rows
              .expand((row) => [
                    _buildThresholdRow(row),
                    if (row != rows.last) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                    ],
                  ])
              .toList(),
        ),
      ),
    );
  }

  Widget _buildThresholdRow(_ThresholdRow row) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: row.color.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(row.icon, color: row.color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(row.label, style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
        ),
        Text(row.value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.success)),
      ],
    );
  }
}
