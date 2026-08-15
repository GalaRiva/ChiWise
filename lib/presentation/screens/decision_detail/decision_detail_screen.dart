import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../data/models/decision_model.dart';
import '../../../data/repositories/decision_repository_impl.dart';
import '../../../domain/repositories/decision_repository.dart';
import '../../providers/decision_flow_provider.dart' show updateDecisionUseCaseProvider;
import '../../widgets/neumorphic/neumorphic_button.dart';

/// Экран просмотра/редактирования уже сохранённого решения. Открывается по
/// параметризованному маршруту `/decision-detail/:id` (см. app_router.dart).
/// По ТЗ — открывается по нажатию на «флажок» локации на карте (карта
/// локаций — Этап 4, ещё не реализована), поэтому на Этапе 3 сюда можно
/// попасть только прямым URL — это ожидаемо.
///
/// `decisionRepositoryProvider.getDraft(id)` (несмотря на название) на самом
/// деле возвращает решение ЛЮБОГО статуса (draft и completed) — см. TODO в
/// decision_repository.dart / комментарий в задании, метод не переименован
/// намеренно, чтобы не расширять зону изменений этого этапа.
class DecisionDetailScreen extends ConsumerStatefulWidget {
  const DecisionDetailScreen({super.key, required this.decisionId});

  final String decisionId;

  @override
  ConsumerState<DecisionDetailScreen> createState() =>
      _DecisionDetailScreenState();
}

class _DecisionDetailScreenState extends ConsumerState<DecisionDetailScreen> {
  DecisionModel? _decision;
  late final List<TextEditingController> _answerControllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // getDraft() синхронный (Hive-чтение) — см. decision_repository.dart,
    // отдельный FutureBuilder не нужен.
    final DecisionRepository repository = ref.read(decisionRepositoryProvider);
    _decision = repository.getDraft(widget.decisionId);

    final DecisionModel? decision = _decision;
    _answerControllers = [
      TextEditingController(text: decision?.answerIfHappens ?? ''),
      TextEditingController(text: decision?.answerIfNotHappens ?? ''),
      TextEditingController(text: decision?.answerNotIfHappens ?? ''),
      TextEditingController(text: decision?.answerNotIfNotHappens ?? ''),
    ];
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    final DecisionModel? current = _decision;
    if (current == null || _isSaving) return;

    setState(() => _isSaving = true);

    final DecisionModel updated = current.copyWith(
      answerIfHappens: _answerControllers[0].text,
      answerIfNotHappens: _answerControllers[1].text,
      answerNotIfHappens: _answerControllers[2].text,
      answerNotIfNotHappens: _answerControllers[3].text,
      updatedAt: DateTime.now(),
    );

    // UpdateDecision usecase уже существует (Этап 2) — просто переиспользуем
    // провайдер, объявленный в decision_flow_provider.dart, не создавая
    // дубликат.
    await ref.read(updateDecisionUseCaseProvider).call(updated);

    if (!mounted) return;
    setState(() {
      _decision = updated;
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.decisionDetailSaved)),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Простое ручное форматирование без DateFormat/intl-локализации даты
    // (в проекте DateFormat пока нигде не используется, а без Flutter SDK в
    // этой среде нельзя проверить компиляцию — минимизируем риск).
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(dateTime.day)}.${twoDigits(dateTime.month)}.${dateTime.year} '
        '${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final DecisionModel? decision = _decision;

    if (decision == null) {
      // Невалидный/отсутствующий id в URL — простая заглушка вместо краша,
      // как явно требует задание.
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              child: Text(
                l10n.decisionDetailNotFound,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    final List<String> questions = [
      l10n.decisionQuestion1,
      l10n.decisionQuestion2,
      l10n.decisionQuestion3,
      l10n.decisionQuestion4,
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _DecisionDates(decision: decision).label(l10n, _formatDateTime),
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 16),
              _DoubtQuoteCard(doubtText: decision.doubtText),
              const SizedBox(height: 24),
              for (int step = 0; step < 4; step++) ...[
                Text(questions[step], style: AppTextStyles.titleMedium),
                const SizedBox(height: 8),
                _AnswerField(controller: _answerControllers[step]),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 8),
              NeumorphicButton(
                label: l10n.decisionDetailSave,
                onPressed: _isSaving ? null : () => _save(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Небольшой хелпер, который собирает строку "создано ... / принято ..." —
/// вынесен, чтобы build() не разрастался условиями.
class _DecisionDates {
  const _DecisionDates({required this.decision});

  final DecisionModel decision;

  String label(
    AppLocalizations l10n,
    String Function(DateTime) formatDateTime,
  ) {
    final String created = formatDateTime(decision.createdAt);
    final DateTime? completedAt = decision.completedAt;
    if (completedAt == null) return created;
    return '$created  →  ${formatDateTime(completedAt)}';
  }
}

/// Карточка с цитатой исходного сомнения — та же визуальная логика, что и
/// _DoubtQuoteCard в decision_flow_screen.dart / decision_summary_screen.dart
/// (приватные виджеты в тех файлах, поэтому копия здесь оправдана заданием —
/// не выносим в общий виджет ради одного этапа).
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
        border: Border.all(color: AppColors.softGold.withValues(alpha: 0.3)),
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

/// Редактируемое поле ответа — авторасширяется по вертикали (maxLines: null),
/// тот же принцип, что и _AnswerField в decision_flow_screen.dart.
class _AnswerField extends StatelessWidget {
  const _AnswerField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: controller,
        maxLines: null,
        minLines: 3,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodyLarge,
        cursorColor: AppColors.turquoise,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
        ),
      ),
    );
  }
}
