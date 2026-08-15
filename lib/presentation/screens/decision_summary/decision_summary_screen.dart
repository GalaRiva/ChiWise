import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/decision_model.dart';
import '../../../data/models/decision_tag.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/decision_repository_impl.dart';
import '../../../domain/repositories/decision_repository.dart';
import '../../../domain/services/mindfulness_evaluator.dart';
import '../../../domain/usecases/decision/complete_decision.dart';
import '../../../services/analytics_service.dart';
import '../../../services/haptics_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/decision_flow_provider.dart';
import '../../providers/rating_flow_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';

/// Usecase-провайдер для этого экрана — по аналогии с
/// createDecisionDraftUseCaseProvider/updateDecisionUseCaseProvider в
/// decision_flow_provider.dart (не добавлен туда напрямую, т.к. задание
/// Этапа 3 ограничивает правки decision_flow_provider.dart — он относится к
/// Этапу 2 и не должен меняться).
final Provider<CompleteDecision> completeDecisionUseCaseProvider =
    Provider<CompleteDecision>(
  (ref) => CompleteDecision(ref.watch(decisionRepositoryProvider)),
);

/// Экран «Принятие решения» — открывается сразу после 5 шагов Квадрата
/// Декарта (маршрут AppRoutes.decisionSummary, см. FLUTTER_ARCHITECTURE_PLAN.md
/// §5, Этап 3). Показывает цитату исходного сомнения и сводку из 4 карточек
/// «вопрос → ответ», используя ТЕКУЩЕЕ состояние decisionFlowProvider (а не
/// перечитывает данные заново из хранилища) — так пользователь видит именно
/// то, что он только что ввёл.
class DecisionSummaryScreen extends ConsumerStatefulWidget {
  const DecisionSummaryScreen({super.key});

  @override
  ConsumerState<DecisionSummaryScreen> createState() =>
      _DecisionSummaryScreenState();
}

class _DecisionSummaryScreenState extends ConsumerState<DecisionSummaryScreen> {
  bool _isSaving = false;

  /// Категория, выбранная пользователем на этом экране (чипы ниже, см.
  /// build()). `null` по умолчанию — категория необязательна
  /// (l10n.decisionTagPickerLabel), заполняется только явным тапом.
  String? _selectedTag;

  Future<void> _acceptDecision() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final DecisionFlowState flowState = ref.read(decisionFlowProvider);
    final DecisionRepository repository = ref.read(decisionRepositoryProvider);

    // Черновик уже лежит в Hive (автосохранение при каждом изменении текста,
    // см. DecisionFlowNotifier._persist) — читаем его, чтобы не пересчитывать
    // createdAt заново, как явно требует задание.
    final DecisionModel? existing = repository.getDraft(flowState.draftId);
    final DateTime now = DateTime.now();
    final DateTime createdAt = existing?.createdAt ?? now;

    // uid на случай (маловероятного) отсутствия existing-записи — тот же
    // паттерн безопасного чтения AuthState, что и в
    // DecisionFlowNotifier._currentUserId (decision_flow_provider.dart).
    final AuthState authState = ref.read(authNotifierProvider);
    final String? authUserId =
        authState is AuthStateAuthenticated ? authState.uid : null;

    final DecisionModel completedDecision = DecisionModel(
      id: flowState.draftId,
      userId: existing?.userId ?? authUserId ?? '',
      doubtText: flowState.doubtText,
      answerIfHappens: flowState.answerIfHappens,
      answerIfNotHappens: flowState.answerIfNotHappens,
      answerNotIfHappens: flowState.answerNotIfHappens,
      answerNotIfNotHappens: flowState.answerNotIfNotHappens,
      tag: _selectedTag ?? existing?.tag,
      status: DecisionStatus.completed,
      locationIndexAtCreation: existing?.locationIndexAtCreation ?? 0,
      createdAt: createdAt,
      updatedAt: now,
      completedAt: now,
      draftToCompleteSeconds: now.difference(createdAt).inSeconds,
      argumentCounts: flowState.argumentCounts,
      usedBackspace: flowState.usedBackspace,
    );

    await ref.read(completeDecisionUseCaseProvider).call(completedDecision);

    // Уровень «Шкалы осознанности» ДО пересчёта — чтобы после узнать, было
    // ли повышение (см. ниже). Этап 9, см. FLUTTER_ARCHITECTURE_PLAN.md §4.
    final MindfulnessLevel? levelBefore =
        ref.read(userProfileProvider)?.mindfulnessLevel;
    // Снимок ачивок ДО пересчёта — чтобы после узнать, какие разблокировались
    // именно сейчас (Этап 12, аналитика — см. ниже).
    final Set<String> achievementsBefore =
        ref.read(userProfileProvider)?.achievements.keys.toSet() ?? {};

    await ref.read(userProfileProvider.notifier).recordDecisionCompleted(completedDecision);

    final MindfulnessLevel? levelAfter =
        ref.read(userProfileProvider)?.mindfulnessLevel;
    final Set<String> achievementsAfter =
        ref.read(userProfileProvider)?.achievements.keys.toSet() ?? {};
    final Set<String> newlyUnlockedKeys =
        achievementsAfter.difference(achievementsBefore);

    // Сброс на новый пустой черновик — чтобы при следующем визите в Квадрат
    // Декарта не осталось старых данных.
    ref.read(decisionFlowProvider.notifier).startNewDraft();

    if (!mounted) return;

    // Аналитика (Этап 12, см. lib/services/analytics_service.dart) —
    // молча деградирует, если Firebase не сконфигурирован в этой среде
    // разработки.
    final AnalyticsService analytics = ref.read(analyticsServiceProvider);
    // ignore: discarded_futures
    analytics.logDecisionCompleted(
      decisionsCount: ref.read(userProfileProvider)?.decisionsCount ?? 0,
    );
    for (final String key in newlyUnlockedKeys) {
      // ignore: discarded_futures
      analytics.logAchievementUnlocked(key);
    }

    // Упрощённая версия "золотых частиц" из ТЗ при повышении уровня —
    // полноценная анимация частиц отложена на Этап 10 (см. задание Этапа 9,
    // Задача 8). Пока — тактильный отклик + snackbar с новым уровнем.
    if (levelBefore != null &&
        levelAfter != null &&
        levelAfter.index > levelBefore.index) {
      ref.read(hapticsServiceProvider).strongTick();
      // ignore: discarded_futures
      analytics.logMindfulnessLevelUp(levelAfter.name);
      final AppLocalizations l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.mindfulnessLevelUpMessage(mindfulnessLevelName(l10n, levelAfter)),
          ),
        ),
      );
    }

    final UserModel? updatedUser = ref.read(userProfileProvider);
    if (updatedUser != null && shouldShowRatingPrompt(updatedUser)) {
      context.go(AppRoutes.ratingFlow);
    } else {
      context.go(AppRoutes.homeMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final DecisionFlowState flowState = ref.watch(decisionFlowProvider);

    final List<_QuestionAnswer> items = [
      _QuestionAnswer(l10n.decisionQuestion1, flowState.answerIfHappens),
      _QuestionAnswer(l10n.decisionQuestion2, flowState.answerIfNotHappens),
      _QuestionAnswer(l10n.decisionQuestion3, flowState.answerNotIfHappens),
      _QuestionAnswer(
        l10n.decisionQuestion4,
        flowState.answerNotIfNotHappens,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Лёгкая анимация успеха — одноразовый "выскакивающий" скейл
              // иконки, без AnimationController (см. задание — не приоритет
              // этого этапа, достаточно простого эффекта).
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1.0),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: const SizedBox(
                    width: 84,
                    height: 84,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.softGold,
                      size: 84,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  l10n.decisionSummaryTitle,
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  l10n.decisionSummarySubtitle,
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              _DoubtQuoteCard(doubtText: flowState.doubtText),
              const SizedBox(height: 24),
              for (final item in items) ...[
                _SummaryCard(question: item.question, answer: item.answer),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              Text(l10n.decisionTagPickerLabel, style: AppTextStyles.bodySecondary),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final DecisionTagOption option in DecisionTagOption.all)
                    _TagChip(
                      option: option,
                      selected: _selectedTag == option.key,
                      onTap: () {
                        setState(() {
                          _selectedTag =
                              _selectedTag == option.key ? null : option.key;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              NeumorphicButton(
                label: l10n.decisionAccept,
                onPressed: _isSaving ? null : _acceptDecision,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionAnswer {
  const _QuestionAnswer(this.question, this.answer);

  final String question;
  final String answer;
}

/// Карточка с цитатой исходного сомнения — тот же стиль, что и
/// _DoubtQuoteCard в decision_flow_screen.dart (приватный виджет там,
/// поэтому переиспользовать напрямую нельзя — копия оправдана заданием).
class _DoubtQuoteCard extends StatelessWidget {
  const _DoubtQuoteCard({required this.doubtText});

  final String doubtText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(color: AppColors.softGold.withOpacity(0.3)),
      ),
      child: Text(
        '«$doubtText»',
        style: AppTextStyles.bodySecondary.copyWith(
          fontStyle: FontStyle.italic,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Один чип выбора категории (см. DecisionTagOption.all) — выбранное
/// состояние закрашено цветом опции, невыбранное — AppColors.surface с
/// текстом того же цвета (доп. акцент вместо textSecondary, чтобы чип было
/// проще узнать до тапа).
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final DecisionTagOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return ChoiceChip(
      label: Text(_tagLabel(l10n, option.labelKey)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: option.color,
      backgroundColor: AppColors.surface,
      labelStyle: AppTextStyles.bodySecondary.copyWith(
        color: selected ? AppColors.deepBlue : option.color,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: option.color.withOpacity(0.5)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
      ),
    );
  }
}

/// `DecisionTagOption.labelKey` — строка, сгенерированный `AppLocalizations`
/// не поддерживает вызов геттера по имени этой строки, поэтому нужен явный
/// switch/map от `labelKey` к соответствующему геттеру `l10n.decisionTagXxx`
/// (тот же паттерн, что `_locationName` в home_map_screen.dart и
/// `_localizedText` в achievements_screen.dart).
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

/// Одна карточка сводной таблицы «вопрос → ответ пользователя».
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            answer.trim().isEmpty ? '—' : answer,
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }
}
