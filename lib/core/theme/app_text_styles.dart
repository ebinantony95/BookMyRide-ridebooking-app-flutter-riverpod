import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.openSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // ─── Display ─────────────────────────────────────────────────────────────
  static TextStyle get displayLarge => _base(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => _base(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      );

  // ─── Headings ─────────────────────────────────────────────────────────────
  static TextStyle get headingLarge => _base(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get heading => _base(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headingSmall => _base(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  // ─── Subheading ───────────────────────────────────────────────────────────
  static TextStyle get subheading => _base(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get subheadingBold => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ─── Body ─────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => _base(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get body => _base(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _base(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get bodySemiBold => _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  // ─── Caption ──────────────────────────────────────────────────────────────
  static TextStyle get caption => _base(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get captionBold => _base(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ─── Label ────────────────────────────────────────────────────────────────
  static TextStyle get label => _base(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle get labelUppercase => _base(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        height: 1.4,
      );

  // ─── Button ───────────────────────────────────────────────────────────────
  static TextStyle get button => _base(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        letterSpacing: 0.3,
      );

  static TextStyle get buttonSmall => _base(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      );

  // ─── Price ────────────────────────────────────────────────────────────────
  static TextStyle get price => _base(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.2,
      );

  static TextStyle get priceLarge => _base(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.1,
      );
}
