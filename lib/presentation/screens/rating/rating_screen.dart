import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../../services/analytics_service.dart';
import '../../../services/review_service.dart';
import '../../providers/rating_flow_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';

/// Экран оценки приложения (маршрут `AppRoutes.ratingFlow`, Этап 7, см. ТЗ и
/// задание Этапа 7). Открывается ТОЛЬКО из
/// `decision_summary_screen.dart` (`_acceptDecision()`) сразу после того,
/// как `UserProfileNotifier.recordDecisionCompleted()` уже обновил профиль
/// — поэтому [ref.read(userProfileProvider)] здесь уже содержит актуальный
/// `decisionsCount`, из которого мы находим ещё не показанную веху (3 или
/// 10, см. [pendingRatingMilestone]).
///
/// 1-3 звезды -> открываем почтовый клиент (см. ReviewService.openSupportEmail);
/// 4-5 звёзд -> нативный запрос на оценку в сторе (см.
/// ReviewService.requestNativeReview). В обоих случаях, а также при явном
/// пропуске — веха помечается показанной и пользователь уходит на карту
/// локаций (`context.go(AppRoutes.homeMap)`, НЕ `pop` — у этого экрана может
/// не быть куда возвращаться, см. задание).
class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({super.key});

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  int _selectedStars = 0;
  bool _isSubmitting = false;

  /// Веха, которую подтверждает этот показ экрана — вычисляется один раз в
  /// [initState] из текущего профиля (см. класс-комментарий), а не на
  /// каждый build(), чтобы не "поехать" на другую веху, если профиль
  /// изменится, пока экран открыт (напр. из-за фонового пересчёта).
  int? _milestone;

  @override
  void initState() {
    super.initState();
    final UserModel? user = ref.read(userProfileProvider);
    _milestone = user == null ? null : pendingRatingMilestone(user);
  }

  Future<void> _markMilestoneShown() async {
    final int? milestone = _milestone;
    if (milestone == null) return;
    await ref.read(ratingFlowProvider.notifier).markPromptShown(milestone);
  }

  Future<void> _onSubmit(AppLocalizations l10n) async {
    if (_selectedStars <= 0 || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final ReviewService reviewService = ref.read(reviewServiceProvider);
    await _markMilestoneShown();

    // ignore: discarded_futures
    ref.read(analyticsServiceProvider).logRatingSubmitted(_selectedStars);

    if (_selectedStars <= 3) {
      await reviewService.openSupportEmail(
        subject: l10n.ratingEmailSubject,
        body: l10n.ratingEmailBody,
      );
    } else {
      await reviewService.requestNativeReview();
    }

    if (!mounted) return;

    final String thanksMessage = _selectedStars <= 3
        ? l10n.ratingLowStarsThanks
        : l10n.ratingHighStarsThanks;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(thanksMessage)),
    );

    // Короткая пауза, чтобы SnackBar успел появиться на экране до того, как
    // context.go() заменит маршрут (и вместе с ним — этот Scaffold): без
    // неё сообщение благодарности пользователь физически не успел бы
    // увидеть. Не блокирует ввод — кнопки уже неактивны из-за _isSubmitting.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    context.go(AppRoutes.homeMap);
  }

  Future<void> _onSkip() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    await _markMilestoneShown();

    if (!mounted) return;
    context.go(AppRoutes.homeMap);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.ratingTitle,
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _StarRow(
                selectedStars: _selectedStars,
                onChanged: _isSubmitting
                    ? null
                    : (stars) => setState(() => _selectedStars = stars),
              ),
              const SizedBox(height: 40),
              NeumorphicButton(
                label: l10n.ratingSubmit,
                onPressed: (_selectedStars > 0 && !_isSubmitting)
                    ? () => _onSubmit(l10n)
                    : null,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isSubmitting ? null : _onSkip,
                child: Text(
                  l10n.ratingSkip,
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ряд из 5 тапабельных звёзд — выбранные (индекс < [selectedStars])
/// закрашены `AppColors.softGold`, остальные — контур
/// `AppColors.textSecondary`. `onChanged == null` блокирует тапы (напр. пока
/// идёт отправка, см. `_isSubmitting`).
class _StarRow extends StatelessWidget {
  const _StarRow({required this.selectedStars, required this.onChanged});

  final int selectedStars;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final int starValue = index + 1;
        final bool filled = starValue <= selectedStars;
        return IconButton(
          iconSize: 40,
          onPressed: onChanged == null ? null : () => onChanged!(starValue),
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled ? AppColors.softGold : AppColors.textSecondary,
          ),
        );
      }),
    );
  }
}
