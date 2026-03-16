import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class ThresholdBar extends StatelessWidget {
  final String title;
  final double min;
  final double safeMin;
  final double safeMax;
  final double max;
  final String unit;

  const ThresholdBar({
    super.key,
    required this.title,
    required this.min,
    required this.safeMin,
    required this.safeMax,
    required this.max,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    double total = max - min;

    double leftRatio = (safeMin - min) / total;
    double safeRatio = (safeMax - safeMin) / total;
    double rightRatio = (max - safeMax) / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TITLE
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          /// RANGE BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [

                /// DANGER LEFT
                Expanded(
                  flex: (leftRatio * 100).round(),
                  child: Container(
                    height: 10,
                    color: AppColors.error.withOpacity(0.3),
                  ),
                ),

                /// SAFE ZONE
                Expanded(
                  flex: (safeRatio * 100).round(),
                  child: Container(
                    height: 10,
                    color: AppColors.success,
                  ),
                ),

                /// DANGER RIGHT
                Expanded(
                  flex: (rightRatio * 100).round(),
                  child: Container(
                    height: 10,
                    color: AppColors.error.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// LABELS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                "Tối thiểu: ${min.toStringAsFixed(0)} $unit",
                style: AppTextStyles.bodySmall,
              ),

              Text(
                "An toàn: ${safeMin.toStringAsFixed(0)} - ${safeMax.toStringAsFixed(0)}",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                ),
              ),

              Text(
                "Tối đa: ${max.toStringAsFixed(0)} $unit",
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}