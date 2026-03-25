import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

class ThresholdBar extends StatelessWidget {
  final String title;
  final double min;      // dangerMin
  final double safeMin;  // normalMin
  final double safeMax;  // normalMax
  final double max;      // dangerMax
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
    final double total = max - min;

    // Flex values within the danger range (min..max)
    final int leftDangerFlex = ((safeMin - min) / total * 100).round().clamp(1, 100);
    final int normalFlex = ((safeMax - safeMin) / total * 100).round().clamp(1, 100);
    final int rightDangerFlex = ((max - safeMax) / total * 100).round().clamp(1, 100);

    // Critical zones shown as fixed end-caps (10% of the inner bar width)
    const int criticalFlex = 10;

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
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 14),

          // ── BAR: CRITICAL | DANGER | NORMAL | DANGER | CRITICAL ──────────
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                // CRITICAL LEFT (< dangerMin)
                Expanded(
                  flex: criticalFlex,
                  child: Container(height: 12, color: AppColors.error),
                ),

                // DANGER LEFT (dangerMin → normalMin)
                Expanded(
                  flex: leftDangerFlex,
                  child: Container(height: 12, color: AppColors.warning),
                ),

                // NORMAL (normalMin → normalMax)
                Expanded(
                  flex: normalFlex,
                  child: Container(height: 12, color: AppColors.success),
                ),

                // DANGER RIGHT (normalMax → dangerMax)
                Expanded(
                  flex: rightDangerFlex,
                  child: Container(height: 12, color: AppColors.warning),
                ),

                // CRITICAL RIGHT (> dangerMax)
                Expanded(
                  flex: criticalFlex,
                  child: Container(height: 12, color: AppColors.error),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── AXIS LABELS ───────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                min.toStringAsFixed(0),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                safeMin.toStringAsFixed(0),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
              ),
              Text(
                safeMax.toStringAsFixed(0),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
              ),
              Text(
                max.toStringAsFixed(0),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── LEGEND ────────────────────────────────────────────────────────
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendItem(
                color: AppColors.success,
                label: 'Bình Thường',
                range: '${safeMin.toStringAsFixed(0)} – ${safeMax.toStringAsFixed(0)} $unit',
              ),
              _LegendItem(
                color: AppColors.warning,
                label: 'Nguy Hiểm',
                range: '${min.toStringAsFixed(0)} – ${safeMin.toStringAsFixed(0)} $unit',
              ),
              _LegendItem(
                color: AppColors.warning,
                label: 'Nguy Hiểm',
                range: '${safeMax.toStringAsFixed(0)} – ${max.toStringAsFixed(0)} $unit',
              ),
              _LegendItem(
                color: AppColors.error,
                label: 'Nghiêm Trọng',
                range: '< ${min.toStringAsFixed(0)}  hoặc  > ${max.toStringAsFixed(0)} $unit',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String range;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$label  $range',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
