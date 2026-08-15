import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/decision_model.dart';
import '../../../data/models/location_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/decision_repository_impl.dart';
import '../../../domain/repositories/decision_repository.dart';
import '../../../domain/usecases/gamification/get_locations_progress.dart';
import '../../providers/auth_provider.dart';
import '../../providers/decision_flow_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/rare_event_overlay.dart';

/// Usecase-провайдер для этого экрана — по аналогии с
/// completeDecisionUseCaseProvider в decision_summary_screen.dart. Чистая
/// функция без состояния, поэтому `const GetLocationsProgress()` достаточно.
final Provider<GetLocationsProgress> getLocationsProgressUseCaseProvider =
    Provider<GetLocationsProgress>((ref) => const GetLocationsProgress());

/// Карта локаций — главный экран приложения (маршрут AppRoutes.homeMap, см.
/// FLUTTER_ARCHITECTURE_PLAN.md §5, Этап 4). Показывает сводку прогресса
/// пользователя и вертикальный список из 16 локаций с матовым стеклом на
/// заблокированных карточках.
class HomeMapScreen extends ConsumerWidget {
  const HomeMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final UserModel? user = ref.watch(userProfileProvider);

    if (user == null) {
      // Профиль ещё грузится/создаётся (см. UserProfileNotifier.build()) —
      // простой индикатор загрузки, как явно требует задание.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.softGold)),
      );
    }

    final List<LocationProgress> progress =
        ref.read(getLocationsProgressUseCaseProvider).call(user.decisionsCount);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => context.push(AppRoutes.achievements),
          ),
          IconButton(
            icon: const Icon(Icons.blur_circular),
            onPressed: () => context.push(AppRoutes.magicBall),
          ),
          IconButton(
            icon: const Icon(Icons.self_improvement),
            onPressed: () => context.push(AppRoutes.profileStats),
          ),
          IconButton(
            icon: const Icon(Icons.bubble_chart_outlined),
            onPressed: () => context.push(AppRoutes.decisionStats),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPadding,
                AppDimens.screenPadding,
                AppDimens.screenPadding,
                8,
              ),
              child: _ProgressSummary(user: user),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPadding,
                  8,
                  AppDimens.screenPadding,
                  96,
                ),
                itemCount: progress.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final LocationProgress item = progress[index];
                  return _LocationCard(
                    progress: item,
                    streakDays: user.streakDays,
                    onTap: () => _onLocationTap(context, ref, l10n, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.softGold,
        foregroundColor: AppColors.deepBlue,
        icon: const Icon(Icons.add),
        label: Text(l10n.homeMapStartDecision, style: AppTextStyles.label.copyWith(color: AppColors.deepBlue)),
        onPressed: () {
          // Гарантированно начинаем с чистого листа, даже если предыдущий
          // флоу был прерван без явной отмены (см. задание Этапа 4).
          ref.read(decisionFlowProvider.notifier).startNewDraft();
          context.push(AppRoutes.decisionFlow);
        },
      ),
    );
  }

  void _onLocationTap(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    LocationProgress item,
  ) {
    if (!item.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeMapLocationLocked)),
      );
      return;
    }

    final AuthState authState = ref.read(authNotifierProvider);
    final String? userId =
        authState is AuthStateAuthenticated ? authState.uid : null;
    final DecisionRepository repository = ref.read(decisionRepositoryProvider);

    final List<DecisionModel> decisions = userId == null
        ? const []
        : repository
            .getAllDrafts(userId)
            .where((decision) =>
                decision.locationIndexAtCreation == item.location.index &&
                decision.status == DecisionStatus.completed)
            .toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.cardRadius)),
      ),
      builder: (sheetContext) {
        return _LocationDecisionsSheet(
          title: l10n.homeMapDecisionsHereTitle,
          emptyText: l10n.homeMapNoDecisionsHere,
          decisions: decisions,
          onSelect: (decision) {
            Navigator.of(sheetContext).pop();
            context.push(AppRoutes.decisionDetailPath(decision.id));
          },
        );
      },
    );
  }
}

/// Краткая сводка прогресса — число решений и текущая серия дней.
class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              l10n.homeMapDecisionsCount(user.decisionsCount),
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.homeMapStreak(user.streakDays),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.softGold),
          ),
        ],
      ),
    );
  }
}

/// Карточка одной локации — название, маркер, матовое стекло если заблокирована.
class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.progress,
    required this.onTap,
    required this.streakDays,
  });

  final LocationProgress progress;
  final VoidCallback onTap;

  /// Текущая серия дней пользователя (UserModel.streakDays) — нужна, чтобы
  /// решить, показывать ли RareEventOverlay (порог streak >= 3, см. задание
  /// Этапа 10c).
  final int streakDays;

  IconData get _markerIcon {
    switch (progress.location.markerType) {
      case LocationMarkerType.flag:
        return Icons.flag;
      case LocationMarkerType.star:
        return Icons.star;
      case LocationMarkerType.planet:
        return Icons.public;
    }
  }

  Color get _markerColor {
    if (!progress.isUnlocked) return AppColors.textSecondary;
    if (progress.isCurrent) return AppColors.softGold;
    return AppColors.turquoise;
  }

  String _name(AppLocalizations l10n) => _locationName(l10n, progress.location.nameKey);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final Widget content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: progress.isCurrent
            ? Border.all(color: AppColors.softGold.withValues(alpha: 0.6))
            : null,
      ),
      child: Row(
        children: [
          Icon(_markerIcon, color: _markerColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(_name(l10n), style: AppTextStyles.titleMedium),
          ),
          if (progress.isUnlocked)
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );

    if (progress.isUnlocked) {
      final Widget card = InkWell(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        onTap: onTap,
        child: content,
      );

      // Редкое небесное явление (затмение, парад планет) — декоративный
      // Lottie-оверлей поверх карточки ТЕКУЩЕЙ локации при streak >= 3, см.
      // LocationModel.rareEventAssets и задание Этапа 10c.
      final bool showRareEvent = progress.isCurrent &&
          streakDays >= 3 &&
          progress.location.rareEventAssets.isNotEmpty;

      if (!showRareEvent) return card;

      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        child: Stack(
          children: [
            card,
            Positioned.fill(
              child: RareEventOverlay(
                // Берём первый (единственный на сегодня) путь анимации у
                // локации — .values.first безопасен, т.к. rareEventAssets
                // проверен на isNotEmpty в showRareEvent выше.
                assetPath: progress.location.rareEventAssets.values.first,
              ),
            ),
          ],
        ),
      );
    }

    // Заблокированная локация — матовое стекло (glassmorphism) поверх
    // карточки + иконка замка, тап ничего не открывает (см. задание).
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      onTap: onTap,
      child: Stack(
        children: [
          content,
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.cardRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  alignment: Alignment.center,
                  color: AppColors.deepBlue.withValues(alpha: 0.35),
                  child: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Содержимое `showModalBottomSheet` со списком завершённых решений локации.
class _LocationDecisionsSheet extends StatelessWidget {
  const _LocationDecisionsSheet({
    required this.title,
    required this.emptyText,
    required this.decisions,
    required this.onSelect,
  });

  final String title;
  final String emptyText;
  final List<DecisionModel> decisions;
  final ValueChanged<DecisionModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPadding,
          20,
          AppDimens.screenPadding,
          20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            if (decisions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(emptyText, style: AppTextStyles.bodySecondary),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: decisions.length,
                  itemBuilder: (context, index) {
                    final DecisionModel decision = decisions[index];
                    final String doubt = decision.doubtText.trim();
                    final String preview =
                        doubt.length > 80 ? '${doubt.substring(0, 80)}…' : doubt;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        preview.isEmpty ? '—' : '«$preview»',
                        style: AppTextStyles.bodyLarge,
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () => onSelect(decision),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `LocationModel.nameKey` — строка, сгенерированный `AppLocalizations` не
/// поддерживает вызов геттера по имени этой строки, поэтому нужен явный
/// switch/map от `nameKey` к соответствующему геттеру `l10n.locationXxx`
/// (см. задание Этапа 4, пункт G).
String _locationName(AppLocalizations l10n, String nameKey) {
  switch (nameKey) {
    case 'locationRiverField':
      return l10n.locationRiverField;
    case 'locationMountain':
      return l10n.locationMountain;
    case 'locationStarPeak':
      return l10n.locationStarPeak;
    case 'locationIsland':
      return l10n.locationIsland;
    case 'locationOceanBoat':
      return l10n.locationOceanBoat;
    case 'locationOracleValley':
      return l10n.locationOracleValley;
    case 'locationEclipseGate':
      return l10n.locationEclipseGate;
    case 'locationSixPlanetsPath':
      return l10n.locationSixPlanetsPath;
    case 'locationSolarSystem':
      return l10n.locationSolarSystem;
    case 'locationConstellations':
      return l10n.locationConstellations;
    case 'locationMilkyWay':
      return l10n.locationMilkyWay;
    case 'locationLargestGalaxy':
      return l10n.locationLargestGalaxy;
    case 'locationUniverse':
      return l10n.locationUniverse;
    case 'locationHumanBrain':
      return l10n.locationHumanBrain;
    case 'locationHomeOutside':
      return l10n.locationHomeOutside;
    case 'locationHomeInsideFinal':
      return l10n.locationHomeInsideFinal;
    default:
      return nameKey;
  }
}
