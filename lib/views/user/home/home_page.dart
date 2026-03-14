import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/health_record.dart';
import '../../../domain/enums/health_type.dart';
import '../../../viewmodels/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  final Function(int, {HealthType? type}) onNavigateToTab;

  const HomePage({super.key, required this.onNavigateToTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchLatestVitals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: viewModel.fetchLatestVitals,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAIInsightCard(),
                const SizedBox(height: 24),
                Text('Your Vitals', style: AppTextStyles.h2),
                const SizedBox(height: 16),
                _buildVitalsGrid(viewModel),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Trends', style: AppTextStyles.h2),
                    GestureDetector(
                      onTap: () => widget.onNavigateToTab(1), // Nav to stats
                      child: Text(
                        'See all',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTrendsList(),
                const SizedBox(height: 80), // FAB space
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAIInsightCard() {
    return Card(
      color: Colors.white,
      shadowColor: Colors.black.withAlpha(13),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('AI Health Insight', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your vitals are stable. Keep maintaining your daily activity and balanced diet. Consider a short walk today.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onNavigateToTab(1), // Nav to stats
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View Analysis'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsGrid(HomeViewModel viewModel) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      children: [
        _buildVitalCard(
          'BLOOD PRESSURE',
          _formatBPValue(viewModel.latestBP),
          'Normal',
          AppColors.primary,
          AppColors.bloodPressureBg,
          Icons.favorite_border,
          onTap: () => widget.onNavigateToTab(1, type: HealthType.BP),
        ),
        _buildVitalCard(
          'BLOOD SUGAR',
          _formatSugarValue(viewModel.latestSugar),
          'Normal',
          Colors.purple,
          AppColors.bloodSugarBg,
          Icons.water_drop_outlined,
          onTap: () => widget.onNavigateToTab(1, type: HealthType.Sugar),
        ),
        _buildVitalCard(
          'WEIGHT',
          _formatWeightValue(viewModel.latestWeight),
          'Steady',
          AppColors.warning,
          AppColors.weightBg,
          Icons.monitor_weight_outlined,
          onTap: () => widget.onNavigateToTab(1, type: HealthType.Weight),
        ),
        _buildVitalCard(
          'SPO2',
          _formatSpo2Value(viewModel.latestSpo2),
          'Normal',
          Colors.blue,
          AppColors.spo2Bg,
          Icons.air,
          onTap: () => widget.onNavigateToTab(1, type: HealthType.Spo2),
        ),
      ],
    );
  }

  String _formatBPValue(HealthRecord? record) {
    if (record == null) return '--/--';
    return '${record.systolic}/${record.diastolic}';
  }

  String _formatSugarValue(HealthRecord? record) {
    if (record == null) return '-- mg/dL';
    return '${record.glucose} ${record.glucoseUnit ?? 'mg/dL'}';
  }

  String _formatWeightValue(HealthRecord? record) {
    if (record == null) return '-- kg';
    return '${record.weight} kg';
  }

  String _formatSpo2Value(HealthRecord? record) {
    if (record == null) return '--%';
    return '${record.spo2}%';
  }

  Widget _buildVitalCard(
    String title,
    String value,
    String status,
    Color mainColor,
    Color bgColor,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: mainColor, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.label.copyWith(fontSize: 10)),
                  const SizedBox(height: 4),
                  Text(value, style: AppTextStyles.h2.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: mainColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: mainColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendsList() {
    return Column(
      children: [
        _buildTrendItem(
          'Active Calories',
          'Daily average',
          '450 kcal',
          '+12% vs last wk',
          AppColors.warning,
          Icons.trending_up,
          AppColors.activeCaloriesBg,
        ),
        const SizedBox(height: 12),
        _buildTrendItem(
          'Sleep Quality',
          'Restorative sleep',
          '7h 20m',
          'Consistent',
          AppColors.primary,
          Icons.nightlight_round,
          AppColors.sleepQualityBg,
        ),
      ],
    );
  }

  Widget _buildTrendItem(
    String title,
    String subtitle,
    String value,
    String status,
    Color color,
    IconData icon,
    Color bgColor,
  ) {
    return Card(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: AppTextStyles.subtitle),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              status,
              style: AppTextStyles.label.copyWith(color: AppColors.success),
            ),
          ],
        ),
      ),
    );
  }
}

