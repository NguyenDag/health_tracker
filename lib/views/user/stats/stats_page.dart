import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

import '../../../domain/entities/health_record.dart';
import '../../../domain/enums/health_type.dart';
import '../../../viewmodels/stats_viewmodel.dart';

class StatsPage extends StatefulWidget {
  final HealthType? initialType;
  const StatsPage({super.key, this.initialType});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    _refreshData(widget.initialType ?? HealthType.BP);
  }

  @override
  void didUpdateWidget(StatsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialType != null && widget.initialType != oldWidget.initialType) {
      _refreshData(widget.initialType!);
    }
  }

  void _refreshData(HealthType type) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StatsViewModel>().setActiveType(type, force: true);
      }
    });
  }

  final List<String> _segments = ['Day', 'Week', 'Month', 'Year'];

  String _getValueForRecord(HealthRecord? record, HealthType type) {
    if (record == null) return '--';
    switch (type) {
      case HealthType.BP:
        return '${record.systolic ?? '--'}/${record.diastolic ?? '--'}';
      case HealthType.Sugar:
        return '${record.glucoseValue ?? '--'}';
      case HealthType.Weight:
        return '${record.weight ?? '--'}';
      case HealthType.Spo2:
        return '${record.spo2 ?? '--'}';
    }
  }

  String _getUnitForType(HealthType type) {
    switch (type) {
      case HealthType.BP:
        return 'mmHg';
      case HealthType.Sugar:
        return 'mg/dL';
      case HealthType.Weight:
        return 'kg';
      case HealthType.Spo2:
        return '%';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsViewModel>(
      builder: (context, viewModel, child) {
        final latestRecord = viewModel.records.isNotEmpty ? viewModel.records.first : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSegmentControl(viewModel),
              const SizedBox(height: 24),
              _buildChartCard(viewModel, latestRecord),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('AI Health Advice', style: AppTextStyles.h2),
                ],
              ),
              const SizedBox(height: 16),
              _buildActionNeededCard(latestRecord),
              const SizedBox(height: 16),
              _buildSmartNutritionCard(latestRecord),
              const SizedBox(height: 16),
              _buildActivityAdviceCard(latestRecord),
              const SizedBox(height: 80), // Padding for BottomNav
            ],
          ),
        );
      },
    );
  }

  Widget _buildSegmentControl(StatsViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_segments.length, (index) {
          final isSelected = viewModel.selectedSegment == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => viewModel.setSegment(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    _segments[index],
                    style: AppTextStyles.subtitle.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChartCard(StatsViewModel viewModel, HealthRecord? latestRecord) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<HealthType>(
                  offset: const Offset(0, 40),
                  onSelected: (HealthType type) {
                    viewModel.setActiveType(type);
                  },
                  itemBuilder: (BuildContext context) => HealthType.values.map((type) {
                    return PopupMenuItem<HealthType>(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                  child: Row(
                    children: [
                      Text(viewModel.activeType.name.toUpperCase().replaceAll('_', ' '), style: AppTextStyles.label),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(_getValueForRecord(latestRecord, viewModel.activeType), style: AppTextStyles.h1.copyWith(fontSize: 36)),
                const SizedBox(width: 4),
                Text(_getUnitForType(viewModel.activeType), style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 4),
            if (viewModel.isLoading)
              const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
            if (!viewModel.isLoading && viewModel.records.isEmpty)
              const SizedBox(height: 150, child: Center(child: Text('No data found'))),
            if (!viewModel.isLoading && viewModel.records.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withAlpha(50)),
                      ),
                    ),
                    child: CustomPaint(
                      painter: _RealChartPainter(viewModel.records, viewModel.activeType),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(viewModel.records.last.createdAt.day.toString() + ' ' + _getMonthName(viewModel.records.last.createdAt.month),
                        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                      Text(viewModel.records.first.createdAt.day.toString() + ' ' + _getMonthName(viewModel.records.first.createdAt.month),
                        style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                    ],
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }

  Widget _buildActionNeededCard(HealthRecord? record) {
    String advice = 'Your vitals are looking good. Keep up the healthy habits!';
    bool warning = false;

    if (record != null) {
      if (record.type == HealthType.Spo2 && (record.spo2 ?? 100) < 95) {
        advice = 'Your SpO2 levels were slightly low (${record.spo2}%) at your last check. Consider some deep breathing exercises.';
        warning = true;
      } else if (record.type == HealthType.BP && (record.systolic ?? 0) > 140) {
        advice = 'Your blood pressure is high (${record.systolic}/${record.diastolic}). Please rest and consult your doctor if it stays high.';
        warning = true;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFF0F2) : const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: (warning ? Colors.red : Colors.green).withAlpha(30), shape: BoxShape.circle),
            child: Icon(warning ? Icons.priority_high : Icons.check_circle, color: warning ? Colors.red : Colors.green, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(warning ? 'Action Needed' : 'Vitals Status', style: AppTextStyles.subtitle.copyWith(color: warning ? Colors.red[900] : Colors.green[900])),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: AppTextStyles.bodyMedium.copyWith(color: warning ? Colors.red[800] : Colors.green[800]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSmartNutritionCard(HealthRecord? record) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8D6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.restaurant, color: Colors.orange[700], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smart Nutrition Tip', style: AppTextStyles.subtitle.copyWith(color: Colors.black87)),
                Text('GENERAL ADVICE', style: AppTextStyles.label.copyWith(color: Colors.orange[800], fontSize: 10)),
                const SizedBox(height: 8),
                Text(
                  'Maintaining a balanced diet with whole grains and leafy greens helps stabilize your health metrics over time.',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivityAdviceCard(HealthRecord? record) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryLight.withAlpha(50), shape: BoxShape.circle),
            child: Icon(Icons.fitness_center, color: Colors.blue[600], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Activity Advice', style: AppTextStyles.subtitle.copyWith(color: Colors.black87)),
                Text('DAILY PROGRESS', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                const SizedBox(height: 8),
                Text(
                  'Regular physical activity like a 20-minute daily walk can significantly improve your cardiovascular health.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _RealChartPainter extends CustomPainter {
  final List<HealthRecord> records;
  final HealthType type;

  _RealChartPainter(this.records, this.type);

  @override
  void paint(Canvas canvas, Size size) {
    if (records.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Reverse records to have chronological order (left to right)
    final dataPoints = records.reversed.toList();
    
    double getVal(HealthRecord r) {
      switch (type) {
        case HealthType.BP:
          return (r.systolic ?? 0).toDouble();
        case HealthType.Sugar:
          return (r.glucoseValue ?? 0).toDouble();
        case HealthType.Weight:
          return (r.weight ?? 0).toDouble();
        case HealthType.Spo2:
          return (r.spo2 ?? 0).toDouble();
      }
    }

    // Find min and max for scaling
    double minVal = getVal(dataPoints[0]);
    double maxVal = getVal(dataPoints[0]);
    
    for (var r in dataPoints) {
      double v = getVal(r);
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }

    // Add some padding to min/max
    if (maxVal == minVal) {
      maxVal += 10;
      minVal -= 10;
    } else {
      double range = maxVal - minVal;
      maxVal += range * 0.2;
      minVal -= range * 0.2;
    }

    double xStep = size.width / (dataPoints.length > 1 ? dataPoints.length - 1 : 1);
    
    for (int i = 0; i < dataPoints.length; i++) {
      double x = i * xStep;
      double normalizedY = (getVal(dataPoints[i]) - minVal) / (maxVal - minVal);
      double y = size.height - (normalizedY * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
    
    // Draw latest point dot
    final lastX = (dataPoints.length - 1) * xStep;
    final lastValNormalized = (getVal(dataPoints.last) - minVal) / (maxVal - minVal);
    final lastY = size.height - (lastValNormalized * size.height);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);
    canvas.drawCircle(Offset(lastX, lastY), 4, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _RealChartPainter oldDelegate) => 
    oldDelegate.records != records || oldDelegate.type != type;
}
