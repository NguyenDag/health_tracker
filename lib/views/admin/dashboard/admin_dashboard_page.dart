import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

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
              Text('Health Metrics Summary', style: AppTextStyles.h2),
              Text(
                'View Report',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(),
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

  Widget _buildSummaryCard() {
    return Card(
      color: Colors.white,
      shadowColor: Colors.black.withAlpha(13),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow('Blood Pressure', 'Avg 120/80', Colors.blue, 0.7),
            const SizedBox(height: 16),
            _buildSummaryRow('SpO2 Levels', 'Avg 98%', AppColors.success, 0.9),
            const SizedBox(height: 16),
            _buildSummaryRow('Weight Trends', 'Stable', AppColors.warning, 0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String status, Color color, double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.subtitle),
              ],
            ),
            Text(status, style: AppTextStyles.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.withAlpha(50),
          color: color,
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}
