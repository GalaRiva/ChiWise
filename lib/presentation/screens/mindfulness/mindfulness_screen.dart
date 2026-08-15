import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../data/models/user_model.dart';
import '../../../domain/services/mindfulness_evaluator.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/mindfulness_scale.dart';

/// Экран «Шкала осознанности» (маршрут `AppRoutes.profileStats`, Этап 9, см.
/// FLUTTER_ARCHITECTURE_PLAN.md §4). Чисто презентационный экран — вся
/// логика начисления очков/уровня уже сделана в
/// `RecordDecisionCompleted`/`MagicBallNotifier` (см.
/// domain/usecases/gamification/record_decision_completed.dart,
/// presentation/providers/magic_ball_provider.dart), здесь только отображение
/// текущего состояния профиля.
class MindfulnessScreen extends ConsumerWidget {
  const MindfulnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserModel? user = ref.watch(userProfileProvider);

    if (user == null) {
      // Профиль ещё грузится/создаётся — тот же паттерн, что и
      // HomeMapScreen/AchievementsScreen.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.softGold)),
      );
    }

    final double progress = mindfulnessProgressToNextLevel(user);
    final int percent = (progress * 100).round();
    final bool isMaxLevel = user.mindfulnessLevel == MindfulnessLevel.guardianOfClarity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.mindfulnessScreenTitle, style: AppTextStyles.titleMedium),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            8,
            AppDimens.screenPadding,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.self_improvement,
                      color: AppColors.softGold,
                      size: 72,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      mindfulnessLevelName(l10n, user.mindfulnessLevel),
                      style: AppTextStyles.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.mindfulnessScoreLabel(user.mindfulnessScore),
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              MindfulnessScaleWidget(progress: progress),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  isMaxLevel
                      ? l10n.mindfulnessMaxLevelReached
                      : l10n.mindfulnessProgressToNext(percent),
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              for (final MindfulnessLevel level in MindfulnessLevel.values) ...[
                _MindfulnessLevelCard(
                  name: mindfulnessLevelName(l10n, level),
                  achieved: user.mindfulnessLevel.index >= level.index,
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка одного из 5 уровней «Шкалы осознанности» — тот же стиль, что и
/// карточки `_LocationCard`/`_AchievementCard` (Container с
/// `AppColors.surface`/`AppDimens.cardRadius`).
class _MindfulnessLevelCard extends StatelessWidget {
  const _MindfulnessLevelCard({
    required this.name,
    required this.achieved,
  });

  final String name;
  final bool achieved;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: achieved
                  ? AppTextStyles.bodyMedium
                  : AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Icon(
            achieved ? Icons.check_circle : Icons.radio_button_unchecked,
            color: achieved ? AppColors.softGold : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
