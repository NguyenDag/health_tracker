import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ThresholdBar extends StatelessWidget {
  final String title;
  final String min;
  final String safe;
  final String max;
  final String unit;

  const ThresholdBar({
    super.key,
    required this.title,
    required this.min,
    required this.safe,
    required this.max,
    required this.unit,

  });

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.7,
              backgroundColor: AppColors.error.withOpacity(0.15),
              valueColor:
              const AlwaysStoppedAnimation(AppColors.success),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(min, style: AppTextStyles.caption),
              Text(
                safe,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                ),
              ),
              Text(max, style: AppTextStyles.caption),
            ],
          )
        ],
      ),
    );
  }
}