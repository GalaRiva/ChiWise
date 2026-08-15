import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';

/// Простая заготовка неоморфной кнопки для Этапа 1 (двойная тень — «свет» +
/// «тень» на тёмном фоне). Полноценный neumorphism (состояния pressed/idle
/// с инверсией теней, тактильный отклик и т.д.) — отдельная задача будущего
/// этапа, см. FLUTTER_ARCHITECTURE_PLAN.md, presentation/widgets/neumorphic.
class NeumorphicButton extends StatelessWidget {
  const NeumorphicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.neumorphicShadowDark,
            offset: Offset(AppDimens.neumorphicOffset, AppDimens.neumorphicOffset),
            blurRadius: AppDimens.neumorphicBlur,
          ),
          BoxShadow(
            color: AppColors.neumorphicShadowLight,
            offset:
                Offset(-AppDimens.neumorphicOffset, -AppDimens.neumorphicOffset),
            blurRadius: AppDimens.neumorphicBlur,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.textPrimary),
                  const SizedBox(width: 12),
                ],
                Text(label, style: AppTextStyles.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
