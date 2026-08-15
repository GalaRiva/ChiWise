import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../providers/decision_flow_provider.dart';
import '../../widgets/breathing_waveform.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';

/// Движок решений — Квадрат Декарта (Этап 2, см.
/// FLUTTER_ARCHITECTURE_PLAN.md §5). Один маршрут (AppRoutes.decisionFlow),
/// внутри которого 5 шагов (0 — ввод сомнения, 1..4 — четыре вопроса)
/// переключаются через IndexedStack — без свайпа, только кнопками «Далее»/
/// «Назад» (в отличие от онбординга), состояние — decisionFlowProvider.
class DecisionFlowScreen extends ConsumerStatefulWidget {
  const DecisionFlowScreen({super.key});

  @override
  ConsumerState<DecisionFlowScreen> createState() =>
      _DecisionFlowScreenState();
}

class _DecisionFlowScreenState extends ConsumerState<DecisionFlowScreen> {
  late final TextEditingController _doubtController;
  late final List<TextEditingController> _answerControllers;

  @override
  void initState() {
    super.initState();
    // Контроллеры инициализируются один раз текущим состоянием провайдера —
    // все 5 полей существуют одновременно (IndexedStack держит их
    // смонтированными), поэтому один контроллер на шаг, без пересоздания при
    // переключении между шагами (иначе терялись бы курсор/scroll-позиция).
    final DecisionFlowState initial = ref.read(decisionFlowProvider);
    _doubtController = TextEditingController(text: initial.doubtText);
    _answerControllers = [
      TextEditingController(text: initial.answerIfHappens),
      TextEditingController(text: initial.answerIfNotHappens),
      TextEditingController(text: initial.answerNotIfHappens),
      TextEditingController(text: initial.answerNotIfNotHappens),
    ];
  }

  @override
  void dispose() {
    _doubtController.dispose();
    for (final TextEditingController controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _confirmCancel(AppLocalizations l10n) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        ),
        title: Text(
          l10n.decisionCancelConfirmTitle,
          style: AppTextStyles.titleMedium,
        ),
        content: Text(
          l10n.decisionCancelConfirmMessage,
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.decisionCancelConfirmNo,
              style: AppTextStyles.bodySecondary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.decisionCancelConfirmYes,
              style: AppTextStyles.label.copyWith(color: AppColors.softGold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(decisionFlowProvider.notifier).cancelAndDiscard();
      if (mounted) context.go(AppRoutes.homeMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final DecisionFlowState flowState = ref.watch(decisionFlowProvider);
    final DecisionFlowNotifier notifier =
        ref.read(decisionFlowProvider.notifier);

    final List<String> questions = [
      l10n.decisionDoubtPrompt,
      l10n.decisionQuestion1,
      l10n.decisionQuestion2,
      l10n.decisionQuestion3,
      l10n.decisionQuestion4,
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.screenPadding,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StepDots(current: flowState.currentStep),
                  IconButton(
                    onPressed: () => _confirmCancel(l10n),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    tooltip: l10n.decisionCancel,
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: flowState.currentStep,
                children: [
                  _DoubtStep(
                    controller: _doubtController,
                    prompt: questions[0],
                    onChanged: notifier.updateDoubtText,
                  ),
                  for (int step = 1; step <= 4; step++)
                    _QuestionStep(
                      doubtText: flowState.doubtText,
                      question: questions[step],
                      controller: _answerControllers[step - 1],
                      onChanged: (text) => notifier.updateAnswer(step, text),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              child: Row(
                children: [
                  if (flowState.currentStep > 0) ...[
                    Expanded(
                      child: NeumorphicButton(
                        label: l10n.decisionBack,
                        onPressed: notifier.goBack,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: NeumorphicButton(
                      label: l10n.decisionNext,
                      onPressed: () {
                        if (flowState.currentStep < 4) {
                          notifier.goNext();
                        } else {
                          // Экран «Принятие решения» (сводная таблица,
                          // сохранение статуса completed) — Этап 3, пока не
                          // реализован; маршрут уже существует как заглушка
                          // (см. app_router.dart).
                          context.go(AppRoutes.decisionSummary);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Точечный индикатор текущего шага (0..4) — визуально похож на
/// _DotsIndicator онбординга, но без свайпа (см. OnboardingScreen).
class _StepDots extends StatelessWidget {
  const _StepDots({required this.current});

  final int current;
  static const int _stepCount = 5;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_stepCount, (index) {
        final bool isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.turquoise : AppColors.textSecondary,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

/// Экран 1/5 — ввод исходного сомнения.
class _DoubtStep extends StatelessWidget {
  const _DoubtStep({
    required this.controller,
    required this.prompt,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String prompt;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.screenPadding,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prompt, style: AppTextStyles.headlineLarge),
          const SizedBox(height: 24),
          _AnswerField(controller: controller, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Экраны 2-5 — вопросы Квадрата Декарта. Сверху всегда цитируется исходное
/// сомнение (введённое на экране 1) — выделенная карточка с курсивом.
class _QuestionStep extends StatelessWidget {
  const _QuestionStep({
    required this.doubtText,
    required this.question,
    required this.controller,
    required this.onChanged,
  });

  final String doubtText;
  final String question;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.screenPadding,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DoubtQuoteCard(doubtText: doubtText),
          const SizedBox(height: 24),
          Text(question, style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          _AnswerField(controller: controller, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Карточка с цитатой исходного сомнения — фиксированно показывается сверху
/// на экранах 2-5.
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

/// Поле ввода ответа — авторасширяется по вертикали (maxLines: null),
/// многострочная клавиатура — прямое требование ТЗ. Под полем — "дыхание
/// интерфейса" (Этап 10a): визуализация скорости набора текста через
/// BreathingWaveform (см. виджет — собственный CustomPainter, без
/// audio_waveforms, т.к. в приложении нет реального аудио для визуализации,
/// только скорость нажатий клавиш).
class _AnswerField extends StatefulWidget {
  const _AnswerField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<_AnswerField> createState() => _AnswerFieldState();
}

class _AnswerFieldState extends State<_AnswerField> {
  double _chaos = 0.0;
  DateTime? _lastKeystroke;
  Timer? _calmDownTimer;

  @override
  void dispose() {
    _calmDownTimer?.cancel();
    super.dispose();
  }

  void _handleChanged(String text) {
    final DateTime now = DateTime.now();
    final DateTime? previous = _lastKeystroke;
    _lastKeystroke = now;

    if (previous != null) {
      final int deltaMs = now.difference(previous).inMilliseconds;
      // Быстрый набор (маленькая пауза между нажатиями) -> высокий chaos;
      // медленный набор/долгая пауза -> низкий. 120мс — типичный интервал
      // быстрой печати, 900мс+ — уже медленный/вдумчивый темп.
      final double instantChaos =
          (1.0 - (deltaMs - 120) / (900 - 120)).clamp(0.0, 1.0);
      setState(() => _chaos = instantChaos);
    }

    // Если пользователь остановился (нет новых нажатий) — через 1.2с
    // "успокаиваем" волну до штиля, а не оставляем последний пик chaos
    // навсегда висеть на экране.
    _calmDownTimer?.cancel();
    _calmDownTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _chaos = 0.0);
    });

    widget.onChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: widget.controller,
            maxLines: null,
            minLines: 4,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.bodyLarge,
            cursorColor: AppColors.turquoise,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
            ),
            onChanged: _handleChanged,
          ),
          const SizedBox(height: 8),
          BreathingWaveform(chaos: _chaos),
        ],
      ),
    );
  }
}
