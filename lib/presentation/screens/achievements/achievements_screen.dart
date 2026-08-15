import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/models/user_model.dart';
import '../../providers/user_profile_provider.dart';

/// Галерея достижений (маршрут `AppRoutes.achievements`, Этап 8b, см.
/// FLUTTER_ARCHITECTURE_PLAN.md §2.4). Чисто презентационный экран — вся
/// логика вычисления условий и запись `UserModel.achievements` уже сделаны
/// в Этапе 8a (AchievementEvaluator, RecordDecisionCompleted), здесь только
/// отображение статического списка `AchievementModel.all`, сгруппированного
/// по категориям, с состоянием "разблокировано/нет" из профиля пользователя.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  static const List<AchievementCategory> _categoryOrder = [
    AchievementCategory.behavioral,
    AchievementCategory.analytical,
    AchievementCategory.narrativeAstro,
    AchievementCategory.magicBall,
  ];

  String _categoryTitle(AppLocalizations l10n, AchievementCategory category) {
    switch (category) {
      case AchievementCategory.behavioral:
        return l10n.achievementsCategoryBehavioral;
      case AchievementCategory.analytical:
        return l10n.achievementsCategoryAnalytical;
      case AchievementCategory.narrativeAstro:
        return l10n.achievementsCategoryNarrativeAstro;
      case AchievementCategory.magicBall:
        return l10n.achievementsCategoryMagicBall;
    }
  }

  IconData _categoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.behavioral:
        return Icons.self_improvement;
      case AchievementCategory.analytical:
        return Icons.psychology_alt;
      case AchievementCategory.narrativeAstro:
        return Icons.auto_awesome;
      case AchievementCategory.magicBall:
        return Icons.blur_circular;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserModel? user = ref.watch(userProfileProvider);

    if (user == null) {
      // Профиль ещё грузится/создаётся — тот же паттерн, что и HomeMapScreen.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.softGold)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.achievementsScreenTitle, style: AppTextStyles.titleMedium),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            8,
            AppDimens.screenPadding,
            32,
          ),
          itemCount: _categoryOrder.length,
          itemBuilder: (context, index) {
            final AchievementCategory category = _categoryOrder[index];
            final List<AchievementModel> items = AchievementModel.all
                .where((achievement) => achievement.category == category)
                .toList();

            if (items.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_categoryIcon(category), color: AppColors.softGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _categoryTitle(l10n, category),
                        style: AppTextStyles.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...items.map((achievement) {
                    final bool unlocked = user.achievements.containsKey(achievement.key);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AchievementCard(
                        achievement: achievement,
                        unlocked: unlocked,
                        unlockedAt: unlocked ? user.achievements[achievement.key] : null,
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Карточка одной ачивки — 4 состояния, см. задание Этапа 8b:
/// 1. обычная разблокированная (полноцветная, галочка "получено");
/// 2. обычная неразблокированная (приглушённая, но с видимым описанием —
///    для несекретных ачивок условие получения не скрывается);
/// 3. секретная неразблокированная (матовое стекло + загадка);
/// 4. секретная разблокированная (полноцветная + флип по тапу на цитату).
class _AchievementCard extends StatefulWidget {
  const _AchievementCard({
    required this.achievement,
    required this.unlocked,
    this.unlockedAt,
  });

  final AchievementModel achievement;
  final bool unlocked;
  final DateTime? unlockedAt;

  @override
  State<_AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<_AchievementCard> {
  // Упрощённая версия "флипа" карточки: настоящая 3D-перспективная
  // трансформация (Matrix4/setEntry) в этой песочнице без Flutter SDK и
  // возможности прогнать `flutter analyze` слишком легко сломать вручную —
  // осознанно заменена на переключение видимого содержимого через
  // AnimatedSwitcher + ScaleTransition. Честный 3D-флип можно добавить
  // позже, в Этапе 10, когда появится возможность скомпилировать проект.
  bool _showingQuote = false;

  void _onTap() {
    final AchievementModel achievement = widget.achievement;
    final bool canFlip = achievement.isSecret && widget.unlocked && achievement.quoteKey != null;
    if (!canFlip) return;
    setState(() => _showingQuote = !_showingQuote);
  }

  String _formattedDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AchievementModel achievement = widget.achievement;

    if (achievement.isSecret && !widget.unlocked) {
      return _buildSecretLocked(l10n);
    }

    if (achievement.isSecret && widget.unlocked) {
      return GestureDetector(
        onTap: _onTap,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: _showingQuote
              ? _buildQuoteSide(l10n, key: const ValueKey('quote'))
              : _buildUnlockedFace(l10n, key: const ValueKey('face')),
        ),
      );
    }

    return widget.unlocked ? _buildUnlockedFace(l10n) : _buildLocked(l10n);
  }

  /// Состояние 1 и 4 (после разгадки) — полноцветная карточка с градиентом.
  Widget _buildUnlockedFace(AppLocalizations l10n, {Key? key}) {
    final AchievementModel achievement = widget.achievement;
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: achievement.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizedText(l10n, achievement.titleKey),
                      style: AppTextStyles.titleMedium,
                    ),
                    if (achievement.descriptionKey != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _localizedText(l10n, achievement.descriptionKey!),
                        style: AppTextStyles.bodySecondary
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                    if (widget.unlockedAt != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _formattedDate(widget.unlockedAt!),
                        style: AppTextStyles.bodySecondary
                            .copyWith(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.check_circle, color: AppColors.softGold, size: 22),
          ),
        ],
      ),
    );
  }

  /// Обратная сторона секретной разблокированной карточки — только цитата.
  Widget _buildQuoteSide(AppLocalizations l10n, {Key? key}) {
    final AchievementModel achievement = widget.achievement;
    return Container(
      key: key,
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: achievement.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Text(
        achievement.quoteKey != null ? '«${_localizedText(l10n, achievement.quoteKey!)}»' : '',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyLarge.copyWith(
          fontStyle: FontStyle.italic,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Состояние 2 — обычная неразблокированная, описание видно.
  Widget _buildLocked(AppLocalizations l10n) {
    final AchievementModel achievement = widget.achievement;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedText(l10n, achievement.titleKey),
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                if (achievement.descriptionKey != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _localizedText(l10n, achievement.descriptionKey!),
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Состояние 3 — секретная неразблокированная: матовое стекло + загадка.
  /// Паттерн `BackdropFilter`/`ImageFilter.blur` скопирован без изменений из
  /// `_LocationCard` в home_map_screen.dart (Stack: обычное содержимое внизу,
  /// Positioned.fill(ClipRRect(BackdropFilter(...))) сверху).
  Widget _buildSecretLocked(AppLocalizations l10n) {
    final AchievementModel achievement = widget.achievement;

    final Widget content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.help_outline, color: AppColors.textSecondary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              achievement.riddleTextKey != null
                  ? _localizedText(l10n, achievement.riddleTextKey!)
                  : '',
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        content,
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.cardRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                alignment: Alignment.center,
                color: AppColors.deepBlue.withOpacity(0.35),
                child: const Icon(
                  Icons.help_outline,
                  color: AppColors.textSecondary,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// `AchievementModel.titleKey`/`riddleTextKey`/`descriptionKey`/`quoteKey` —
/// строки, а сгенерированный `AppLocalizations` не поддерживает вызов
/// геттера по динамическому имени, поэтому нужен явный switch/map (тот же
/// паттерн, что и `_locationName(...)` в конце home_map_screen.dart).
String _localizedText(AppLocalizations l10n, String key) {
  switch (key) {
    case 'achOrbitalStabilityTitle':
      return l10n.achOrbitalStabilityTitle;
    case 'achOrbitalStabilityDesc':
      return l10n.achOrbitalStabilityDesc;
    case 'achNightOwlSageTitle':
      return l10n.achNightOwlSageTitle;
    case 'achNightOwlSageDesc':
      return l10n.achNightOwlSageDesc;
    case 'achBalanceMasterTitle':
      return l10n.achBalanceMasterTitle;
    case 'achBalanceMasterDesc':
      return l10n.achBalanceMasterDesc;
    case 'achDeepAnalysisTitle':
      return l10n.achDeepAnalysisTitle;
    case 'achDeepAnalysisDesc':
      return l10n.achDeepAnalysisDesc;
    case 'achIllusionBreakerTitle':
      return l10n.achIllusionBreakerTitle;
    case 'achIllusionBreakerDesc':
      return l10n.achIllusionBreakerDesc;
    case 'achEclipseCatcherTitle':
      return l10n.achEclipseCatcherTitle;
    case 'achEclipseCatcherDesc':
      return l10n.achEclipseCatcherDesc;
    case 'achPlanetParadeTitle':
      return l10n.achPlanetParadeTitle;
    case 'achPlanetParadeDesc':
      return l10n.achPlanetParadeDesc;
    case 'achLightMindTitle':
      return l10n.achLightMindTitle;
    case 'achLightMindDesc':
      return l10n.achLightMindDesc;
    case 'achMagicResonanceTitle':
      return l10n.achMagicResonanceTitle;
    case 'achMagicResonanceDesc':
      return l10n.achMagicResonanceDesc;
    case 'achFateTesterTitle':
      return l10n.achFateTesterTitle;
    case 'achFateTesterDesc':
      return l10n.achFateTesterDesc;
    case 'achEclipseObserverTitle':
      return l10n.achEclipseObserverTitle;
    case 'achEclipseObserverRiddle':
      return l10n.achEclipseObserverRiddle;
    case 'achEclipseObserverDesc':
      return l10n.achEclipseObserverDesc;
    case 'achEclipseObserverQuote':
      return l10n.achEclipseObserverQuote;
    case 'achPerfectAlignmentTitle':
      return l10n.achPerfectAlignmentTitle;
    case 'achPerfectAlignmentRiddle':
      return l10n.achPerfectAlignmentRiddle;
    case 'achPerfectAlignmentDesc':
      return l10n.achPerfectAlignmentDesc;
    case 'achPerfectAlignmentQuote':
      return l10n.achPerfectAlignmentQuote;
    case 'achOrhekiaHeightTitle':
      return l10n.achOrhekiaHeightTitle;
    case 'achOrhekiaHeightRiddle':
      return l10n.achOrhekiaHeightRiddle;
    case 'achOrhekiaHeightDesc':
      return l10n.achOrhekiaHeightDesc;
    case 'achOrhekiaHeightQuote':
      return l10n.achOrhekiaHeightQuote;
    case 'achOracleWhisperTitle':
      return l10n.achOracleWhisperTitle;
    case 'achOracleWhisperRiddle':
      return l10n.achOracleWhisperRiddle;
    case 'achOracleWhisperDesc':
      return l10n.achOracleWhisperDesc;
    case 'achOracleWhisperQuote':
      return l10n.achOracleWhisperQuote;
    default:
      return key; // защита от опечатки — не должно происходить в норме
  }
}
