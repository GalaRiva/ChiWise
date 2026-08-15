import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/decision_model.dart';
import '../../data/repositories/decision_repository_impl.dart';
import '../../domain/repositories/decision_repository.dart';
import '../../domain/usecases/decision/create_decision_draft.dart';
import '../../domain/usecases/decision/update_decision.dart';
import 'auth_provider.dart';

final Provider<CreateDecisionDraft> createDecisionDraftUseCaseProvider =
    Provider<CreateDecisionDraft>(
  (ref) => CreateDecisionDraft(ref.watch(decisionRepositoryProvider)),
);

final Provider<UpdateDecision> updateDecisionUseCaseProvider =
    Provider<UpdateDecision>(
  (ref) => UpdateDecision(ref.watch(decisionRepositoryProvider)),
);

/// Состояние движка решений — Квадрат Декарта (Этап 2, см.
/// FLUTTER_ARCHITECTURE_PLAN.md §2.2, §5). `currentStep`: 0 — ввод сомнения,
/// 1..4 — четыре вопроса Квадрата.
class DecisionFlowState {
  const DecisionFlowState({
    required this.draftId,
    this.currentStep = 0,
    this.doubtText = '',
    this.answerIfHappens = '',
    this.answerIfNotHappens = '',
    this.answerNotIfHappens = '',
    this.answerNotIfNotHappens = '',
    this.argumentCounts = const {},
    this.usedBackspace = true,
  });

  final String draftId;
  final int currentStep;
  final String doubtText;
  final String answerIfHappens;
  final String answerIfNotHappens;
  final String answerNotIfHappens;
  final String answerNotIfNotHappens;

  /// 'q1'..'q4' -> число непустых строк в соответствующем блоке.
  final Map<String, int> argumentCounts;

  /// true, если пользователь ни разу не «стирал» текст за весь Квадрат —
  /// условие секретной ачивки «Высота Орхехии» (см. эвристику в updateAnswer).
  final bool usedBackspace;

  DecisionFlowState copyWith({
    String? draftId,
    int? currentStep,
    String? doubtText,
    String? answerIfHappens,
    String? answerIfNotHappens,
    String? answerNotIfHappens,
    String? answerNotIfNotHappens,
    Map<String, int>? argumentCounts,
    bool? usedBackspace,
  }) {
    return DecisionFlowState(
      draftId: draftId ?? this.draftId,
      currentStep: currentStep ?? this.currentStep,
      doubtText: doubtText ?? this.doubtText,
      answerIfHappens: answerIfHappens ?? this.answerIfHappens,
      answerIfNotHappens: answerIfNotHappens ?? this.answerIfNotHappens,
      answerNotIfHappens: answerNotIfHappens ?? this.answerNotIfHappens,
      answerNotIfNotHappens:
          answerNotIfNotHappens ?? this.answerNotIfNotHappens,
      argumentCounts: argumentCounts ?? this.argumentCounts,
      usedBackspace: usedBackspace ?? this.usedBackspace,
    );
  }

  /// Текущий текст ответа для шага 1..4 (0 — экран ввода сомнения, здесь не
  /// используется).
  String answerForStep(int step) {
    switch (step) {
      case 1:
        return answerIfHappens;
      case 2:
        return answerIfNotHappens;
      case 3:
        return answerNotIfHappens;
      case 4:
        return answerNotIfNotHappens;
      default:
        return '';
    }
  }
}

/// Riverpod-нотифаер флоу заполнения Квадрата Декарта. Presentation-слой
/// (DecisionFlowScreen) вызывает методы этого класса, а не usecases/репозиторий
/// напрямую — тот же стиль, что и AuthNotifier (см. auth_provider.dart).
class DecisionFlowNotifier extends Notifier<DecisionFlowState> {
  // ВАЖНО (неуверенность без Flutter/Dart SDK в этой среде): в uuid ^4.x
  // конструктор `Uuid()` не гарантированно const (в отличие от uuid ^3.x) —
  // используем `static final`, а не `static const`, чтобы не словить ошибку
  // компиляции "not a constant expression", если это так.
  static final Uuid _uuid = Uuid();

  @override
  DecisionFlowState build() {
    return DecisionFlowState(draftId: _uuid.v4());
  }

  /// Начинает новый черновик «с чистого листа» — новый id, все поля сброшены.
  void startNewDraft() {
    state = DecisionFlowState(draftId: _uuid.v4());
  }

  void updateDoubtText(String text) {
    state = state.copyWith(doubtText: text);
    _persist();
  }

  /// step: 1..4 — соответствующий блок Квадрата Декарта.
  void updateAnswer(int step, String text) {
    final String previousText = state.answerForStep(step);

    // Эвристика usedBackspace (задокументировано в задании как не 100%
    // точная эвристика, это нормально для MVP): если новый текст короче
    // предыдущего — считаем, что пользователь стирал символы
    // (backspace/delete/вырезание выделения). Не различает «настоящий»
    // backspace от замены выделенного фрагмента более коротким текстом, но
    // этого достаточно для секретной ачивки «Высота Орхехии».
    final bool usedBackspaceNow =
        text.length < previousText.length ? true : state.usedBackspace;

    final Map<String, int> argumentCounts =
        Map<String, int>.from(state.argumentCounts);
    argumentCounts['q$step'] = _countNonEmptyLines(text);

    DecisionFlowState next = state.copyWith(
      argumentCounts: argumentCounts,
      usedBackspace: usedBackspaceNow,
    );

    if (step == 1) {
      next = next.copyWith(answerIfHappens: text);
    } else if (step == 2) {
      next = next.copyWith(answerIfNotHappens: text);
    } else if (step == 3) {
      next = next.copyWith(answerNotIfHappens: text);
    } else if (step == 4) {
      next = next.copyWith(answerNotIfNotHappens: text);
    }

    state = next;
    _persist();
  }

  int _countNonEmptyLines(String text) {
    return text.split('\n').where((line) => line.trim().isNotEmpty).length;
  }

  void goNext() {
    if (state.currentStep >= 4) return;
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void goBack() {
    if (state.currentStep <= 0) return;
    state = state.copyWith(currentStep: state.currentStep - 1);
  }

  /// Удаляет черновик из Hive и сбрасывает состояние (новый пустой черновик) —
  /// вызывается при подтверждении диалога отмены (крестик на экранах
  /// Квадрата Декарта). Навигацию на AppRoutes.homeMap выполняет вызывающий
  /// экран после await этого метода.
  Future<void> cancelAndDiscard() async {
    final DecisionRepository repository =
        ref.read(decisionRepositoryProvider);
    await repository.deleteDraft(state.draftId);
    state = DecisionFlowState(draftId: _uuid.v4());
  }

  /// uid текущего пользователя. До экрана Квадрата Декарта пользователь уже
  /// проходит через redirect авторизации в go_router (см. app_router.dart),
  /// поэтому на практике здесь почти всегда AuthStateAuthenticated — но
  /// всё равно проверяем тип состояния, а не полагаемся на `!`.
  String? _currentUserId() {
    final AuthState authState = ref.read(authNotifierProvider);
    if (authState is AuthStateAuthenticated) return authState.uid;
    return null;
  }

  /// Автосохранение в Hive при каждом изменении текста (MVP — без дебаунса,
  /// см. задание Этапа 2). Сохраняет исходный `createdAt` черновика, если он
  /// уже существовал (важно для будущего расчёта `draftToCompleteSeconds`,
  /// Этап 3/8) — берёт его из уже сохранённой записи в Hive перед перезаписью.
  Future<void> _persist() async {
    final String? userId = _currentUserId();
    if (userId == null) {
      // uid недоступен (edge case, гонка состояний при старте) — не падаем,
      // просто не сохраняем этот кадр, следующий updateAnswer/updateDoubtText
      // попробует снова.
      return;
    }

    final DecisionRepository repository =
        ref.read(decisionRepositoryProvider);
    final DecisionModel? existing = repository.getDraft(state.draftId);
    final DateTime now = DateTime.now();

    final DecisionModel decision = DecisionModel(
      id: state.draftId,
      userId: userId,
      doubtText: state.doubtText,
      answerIfHappens: state.answerIfHappens,
      answerIfNotHappens: state.answerIfNotHappens,
      answerNotIfHappens: state.answerNotIfHappens,
      answerNotIfNotHappens: state.answerNotIfNotHappens,
      status: DecisionStatus.draft,
      // TODO(Этап 4): брать текущую локацию пользователя из профиля.
      locationIndexAtCreation: existing?.locationIndexAtCreation ?? 0,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      argumentCounts: state.argumentCounts,
      usedBackspace: state.usedBackspace,
    );

    if (existing == null) {
      await ref.read(createDecisionDraftUseCaseProvider).call(decision);
    } else {
      await ref.read(updateDecisionUseCaseProvider).call(decision);
    }
  }
}

final NotifierProvider<DecisionFlowNotifier, DecisionFlowState>
    decisionFlowProvider =
    NotifierProvider<DecisionFlowNotifier, DecisionFlowState>(
  DecisionFlowNotifier.new,
);
