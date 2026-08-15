import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// Неоморфная «капсула»-полоска прогресса «Шкалы осознанности» (Этап 9, см.
/// FLUTTER_ARCHITECTURE_PLAN.md §4). Чисто презентационный виджет — сам не
/// читает провайдеры, принимает готовый [progress] (0.0..1.0) от вызывающего
/// экрана (mindfulness_screen.dart), который берёт его из
/// `mindfulnessProgressToNextLevel` (domain/services/mindfulness_evaluator.dart).
///
/// Анимация сделана через `TweenAnimationBuilder` (без ручного
/// `AnimationController`/`dispose()`) — при каждом ребилде с новым
/// [progress] полоска плавно "дотекает" от предыдущего значения к новому.
class MindfulnessScaleWidget extends StatelessWidget {
  const MindfulnessScaleWidget({
    super.key,
    required this.progress,
  });

  /// 0.0..1.0 — прогресс к следующему уровню.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final double clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      height: 30,
      width: double.infinity,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.neumorphicShadowDark,
              offset: Offset(
                AppDimens.neumorphicOffset,
                AppDimens.neumorphicOffset,
              ),
              blurRadius: AppDimens.neumorphicBlur,
            ),
            BoxShadow(
              color: AppColors.neumorphicShadowLight,
              offset: Offset(
                -AppDimens.neumorphicOffset,
                -AppDimens.neumorphicOffset,
              ),
              blurRadius: AppDimens.neumorphicBlur,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: clampedProgress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  widthFactor: value.clamp(0.0, 1.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.deepBlue,
                          AppColors.emerald,
                          AppColors.turquoise,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
