import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int _selectedSegment = 2; // Default to 'Month'

  final List<String> _segments = ['Day', 'Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSegmentControl(),
          const SizedBox(height: 24),
          _buildChartCard(),
          const SizedBox(height: 32),
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('AI Health Advice', style: AppTextStyles.h2),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionNeededCard(),
          const SizedBox(height: 16),
          _buildSmartNutritionCard(),
          const SizedBox(height: 16),
          _buildActivityAdviceCard(),
          const SizedBox(height: 80), // Padding for BottomNav
        ],
      ),
    );
  }

  Widget _buildSegmentControl() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_segments.length, (index) {
          final isSelected = _selectedSegment == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSegment = index;
                });
              },
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

  Widget _buildChartCard() {
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
                Row(
                  children: [
                    Text('BLOOD PRESSURE', style: AppTextStyles.label),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                  ],
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
                Text('120/80', style: AppTextStyles.h1.copyWith(fontSize: 36)),
                const SizedBox(width: 4),
                Text('mmHg', style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_down, size: 12, color: AppColors.success),
                      const SizedBox(width: 2),
                      Text('2%', style: AppTextStyles.label.copyWith(color: AppColors.success, fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('vs last month', style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 24),
            // Placeholder for a chart
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withAlpha(50)),
                ),
              ),
              child: CustomPaint(
                painter: _MockChartPainter(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 OCT', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                Text('10 OCT', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                Text('20 OCT', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                Text('30 OCT', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionNeededCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red.withAlpha(30), shape: BoxShape.circle),
            child: const Icon(Icons.priority_high, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Action Needed', style: AppTextStyles.subtitle.copyWith(color: Colors.red[900])),
                const SizedBox(height: 4),
                Text(
                  'Your SpO2 levels were slightly low (94%) this morning. Consider some deep breathing exercises.',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.red[800]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSmartNutritionCard() {
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
                Text('BASED ON GLUCOSE LEVELS', style: AppTextStyles.label.copyWith(color: Colors.orange[800], fontSize: 10)),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.black87),
                    children: [
                      const TextSpan(text: 'Great job keeping your fasting glucose stable this week! Try adding more '),
                      TextSpan(text: 'fiber', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900])),
                      const TextSpan(text: ' to your dinner to maintain these levels tomorrow.'),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivityAdviceCard() {
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
                Text('WEIGHT GOAL PROGRESS', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: "You've been consistent with your 5kg weight goal. A "),
                      TextSpan(text: '20-minute brisk walk', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[600])),
                      const TextSpan(text: ' today would help maintain your metabolic rate and mood.'),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MockChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.5, size.width * 0.3, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.45, size.height * 0.9, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.55, size.height * 0.1, size.width * 0.6, size.height * 0.1);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.1, size.width * 0.8, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.8, size.width, size.height * 0.2);

    canvas.drawPath(path, paint);
    
    // Draw highlight dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 4, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
