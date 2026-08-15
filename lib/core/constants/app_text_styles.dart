import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Иерархия типографики из ТЗ: Montserrat — заголовки/акценты,
/// Inter — основной текст (карточки, поля ввода Квадрата Декарта).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headlineLarge => GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.montserrat(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySecondary => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  /// Кнопки: ДАЛЕЕ, СОХРАНИТЬ и т.д. — небольшой letterSpacing.
  static TextStyle get label => GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: AppColors.textPrimary,
      );
}
