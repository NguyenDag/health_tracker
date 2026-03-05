import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

// Shared threshold data — can later be moved to a ViewModel/Repository
class ThresholdConfig {
  static RangeValues bloodPressureSystolic = const RangeValues(90, 120);
  static RangeValues bloodPressureDiastolic = const RangeValues(60, 80);
  static RangeValues bloodGlucoseFasting = const RangeValues(70, 100);
  static RangeValues oxygenSpO2 = const RangeValues(95, 100);
  static RangeValues targetBMI = const RangeValues(18.5, 24.9);
}

class _RangeMetric {
  final String name;
  final IconData icon;
  final Color color;
  final String unit;
  final String rangeLabel;
  RangeValues values;
  final RangeValues limits;
  final int divisions;

  _RangeMetric({
    required this.name,
    required this.icon,
    required this.color,
    required this.unit,
    required this.rangeLabel,
    required this.values,
    required this.limits,
    required this.divisions,
  });
}

class AdminThresholdsPage extends StatefulWidget {
  const AdminThresholdsPage({super.key});

  @override
  State<AdminThresholdsPage> createState() => _AdminThresholdsPageState();
}

class _AdminThresholdsPageState extends State<AdminThresholdsPage> {
  bool _hasChanges = false;

  late final List<_RangeMetric> _metrics;

  static const _defaultSystolic = RangeValues(90, 120);
  static const _defaultDiastolic = RangeValues(60, 80);
  static const _defaultGlucose = RangeValues(70, 100);
  static const _defaultSpO2 = RangeValues(95, 100);
  static const _defaultBMI = RangeValues(18.5, 24.9);

  @override
  void initState() {
    super.initState();
    _metrics = [
      _RangeMetric(
        name: 'Blood Pressure',
        icon: Icons.favorite_border,
        color: AppColors.error,
        unit: 'mmHg',
        rangeLabel: 'Systolic Range',
        values: ThresholdConfig.bloodPressureSystolic,
        limits: const RangeValues(60, 200),
        divisions: 140,
      ),
      _RangeMetric(
        name: 'Blood Pressure',
        icon: Icons.favorite_border,
        color: AppColors.error,
        unit: 'mmHg',
        rangeLabel: 'Diastolic Range',
        values: ThresholdConfig.bloodPressureDiastolic,
        limits: const RangeValues(40, 130),
        divisions: 90,
      ),
      _RangeMetric(
        name: 'Blood Glucose',
        icon: Icons.water_drop_outlined,
        color: Colors.orange,
        unit: 'mg/dL',
        rangeLabel: 'Fasting Range',
        values: ThresholdConfig.bloodGlucoseFasting,
        limits: const RangeValues(50, 200),
        divisions: 150,
      ),
      _RangeMetric(
        name: 'Oxygen (SpO2)',
        icon: Icons.air,
        color: AppColors.success,
        unit: '%',
        rangeLabel: 'Healthy Range',
        values: ThresholdConfig.oxygenSpO2,
        limits: const RangeValues(70, 100),
        divisions: 30,
      ),
      _RangeMetric(
        name: 'Target BMI',
        icon: Icons.monitor_weight_outlined,
        color: Colors.deepPurple,
        unit: '',
        rangeLabel: 'Normal Weight',
        values: ThresholdConfig.targetBMI,
        limits: const RangeValues(10, 40),
        divisions: 60,
      ),
    ];
  }

  String _fmt(double v) => v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reset to Defaults', style: AppTextStyles.h3),
        content: Text(
          'All thresholds will be reset to global default values. Continue?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.subtitle),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() {
                _metrics[0].values = _defaultSystolic;
                _metrics[1].values = _defaultDiastolic;
                _metrics[2].values = _defaultGlucose;
                _metrics[3].values = _defaultSpO2;
                _metrics[4].values = _defaultBMI;
                _hasChanges = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thresholds reset to defaults.'),
                  backgroundColor: AppColors.textSecondary,
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _save() {
    ThresholdConfig.bloodPressureSystolic = _metrics[0].values;
    ThresholdConfig.bloodPressureDiastolic = _metrics[1].values;
    ThresholdConfig.bloodGlucoseFasting = _metrics[2].values;
    ThresholdConfig.oxygenSpO2 = _metrics[3].values;
    ThresholdConfig.targetBMI = _metrics[4].values;
    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Threshold settings saved.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Global Thresholds', style: AppTextStyles.h3),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _hasChanges ? _save : null,
            child: Text(
              'Save',
              style: AppTextStyles.subtitle.copyWith(
                color: _hasChanges ? AppColors.success : AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text('Safe Ranges', style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Text(
            'Configure the default safety thresholds for patient vitals. Values outside these ranges will trigger alerts for new users.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Blood Pressure card (2 ranges grouped)
          _buildGroupedCard(
            name: 'Blood Pressure',
            icon: Icons.favorite_border,
            color: AppColors.error,
            metrics: [_metrics[0], _metrics[1]],
          ),
          const SizedBox(height: 12),

          // Blood Glucose
          _buildSingleCard(_metrics[2]),
          const SizedBox(height: 12),

          // SpO2
          _buildSingleCard(_metrics[3]),
          const SizedBox(height: 12),

          // BMI
          _buildSingleCard(_metrics[4]),
          const SizedBox(height: 24),

          // Reset button
          OutlinedButton.icon(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.restart_alt, color: AppColors.error, size: 18),
            label: const Text(
              'Reset to Global Defaults',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGroupedCard({
    required String name,
    required IconData icon,
    required Color color,
    required List<_RangeMetric> metrics,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _metricHeader(icon, name, color),
          const SizedBox(height: 12),
          ...metrics.map((m) => _buildRangeRow(m)),
        ],
      ),
    );
  }

  Widget _buildSingleCard(_RangeMetric metric) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _metricHeader(metric.icon, metric.name, metric.color),
          const SizedBox(height: 12),
          _buildRangeRow(metric),
        ],
      ),
    );
  }

  Widget _metricHeader(IconData icon, String name, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(name, style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary, fontSize: 16)),
      ],
    );
  }

  Widget _buildRangeRow(_RangeMetric metric) {
    final unitSuffix = metric.unit.isNotEmpty ? ' ${metric.unit}' : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(metric.rangeLabel, style: AppTextStyles.bodyMedium),
              Text(
                '${_fmt(metric.values.start)} - ${_fmt(metric.values.end)}$unitSuffix',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.success),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                _fmt(metric.limits.start),
                style: AppTextStyles.bodySmall,
              ),
              Expanded(
                child: RangeSlider(
                  values: metric.values,
                  min: metric.limits.start,
                  max: metric.limits.end,
                  divisions: metric.divisions,
                  activeColor: AppColors.success,
                  inactiveColor: Colors.grey.withAlpha(60),
                  onChanged: (v) => setState(() {
                    metric.values = v;
                    _hasChanges = true;
                  }),
                ),
              ),
              Text(
                _fmt(metric.limits.end),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
