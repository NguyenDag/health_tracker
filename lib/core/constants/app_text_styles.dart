import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();
  // Headings
  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Emphasis
  static TextStyle get subtitle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const heading1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800,
    color: AppColors.textDark, letterSpacing: -0.5,
  );
  static const heading2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w800,
    color: AppColors.textDark, letterSpacing: -0.3,
  );
  static const heading3 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
  static const body = TextStyle(
    fontSize: 14, color: AppColors.textGrey, height: 1.55,
  );
  /*static const label = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMid,
  );*/
  static const hint = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textHint, letterSpacing: 1.5,
  );
  static const badge = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.primary, letterSpacing: 1.4,
  );
  static const link = TextStyle(
    fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600,
  );
}
