import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../data/models/decision_model.dart';
import '../../../data/models/decision_tag.dart';
import '../../../data/repositories/decision_repository_impl.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bubble_chart/decision_bubble_chart.dart';

/// Экран «Статистика» (Этап 10b, маршрут AppRoutes.decisionStats) —
/// bubble chart истории ЗАВЕРШЁННЫХ решений: размер пузыря = объём текста
/// (см. DecisionBubbleChart._volumeOf), цвет = категория (DecisionTagOption,
/// выбирается на decision_summary_screen.dart). См. FLUTTER_ARCHITECTURE_PLAN.md.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AuthState authState = ref.watch(authNotifierProvider);
    final String? userId = authState is AuthStateAuthenticated ? authState.uid : null;

    final List<DecisionModel> completedDecisions = userId == null
        ? const []
        : ref
            .watch(decisionRepositoryProvider)
            .getAllDrafts(userId)
            .where((d) => d.status == DecisionStatus.completed)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.statsScreenTitle, style: AppTextStyles.titleMedium),
      ),
      body: SafeArea(
        child: completedDecisions.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.screenPadding),
                  child: Text(
                    l10n.statsEmptyState,
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.screenPadding),
                child: Column(
                  children: [
                    DecisionBubbleChart(decisions: completedDecisions),
                    const SizedBox(height: 20),
                    const _TagLegend(),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Легенда цветов категорий под графиком — точка + название для каждой
/// DecisionTagOption.all.
class _TagLegend extends StatelessWidget {
  const _TagLegend();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 16,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (final DecisionTagOption option in DecisionTagOption.all)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: option.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(_tagLabel(l10n, option.labelKey), style: AppTextStyles.bodySecondary),
            ],
          ),
      ],
    );
  }
}

/// `DecisionTagOption.labelKey` — строка, сгенерированный `AppLocalizations`
/// не поддерживает вызов геттера по имени этой строки, поэтому нужен явный
/// switch/map от `labelKey` к соответствующему геттеру `l10n.decisionTagXxx`
/// (тот же паттерн, что `_locationName` в home_map_screen.dart и
/// `_localizedText` в achievements_screen.dart; дублируется здесь, а не
/// переиспользуется из decision_summary_screen.dart, т.к. этот хелпер там
/// приватный — тот же подход, что и в остальном проекте, см. комментарий
/// _DoubtQuoteCard в decision_summary_screen.dart).
String _tagLabel(AppLocalizations l10n, String labelKey) {
  switch (labelKey) {
    case 'decisionTagWork':
      return l10n.decisionTagWork;
    case 'decisionTagRelationships':
      return l10n.decisionTagRelationships;
    case 'decisionTagHealth':
      return l10n.decisionTagHealth;
    case 'decisionTagFinances':
      return l10n.decisionTagFinances;
    case 'decisionTagPersonalGrowth':
      return l10n.decisionTagPersonalGrowth;
    case 'decisionTagOther':
      return l10n.decisionTagOther;
    default:
      return labelKey;
  }
}
