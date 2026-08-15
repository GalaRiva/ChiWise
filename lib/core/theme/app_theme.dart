import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_text_styles.dart';

/// Глобальная ThemeData. Неоморфные/glass-эффекты реализованы точечно
/// в presentation/widgets/neumorphic и presentation/widgets/glass —
/// ThemeData задаёт только базовые цвета/типографику/форму.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.turquoise,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.turquoise,
        secondary: AppColors.softGold,
        surface: AppColors.surface,
        onPrimary: AppColors.deepBlue,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySecondary,
        labelLarge: AppTextStyles.label,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.turquoise,
          foregroundColor: AppColors.deepBlue,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          ),
          textStyle: AppTextStyles.label,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(AppDimens.screenPadding),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          borderSide: BorderSide.none,
        ),
        hintStyle: AppTextStyles.bodySecondary,
      ),
    );
  }
}
