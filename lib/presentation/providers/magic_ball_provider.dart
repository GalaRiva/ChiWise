import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/magic_ball_answer_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/services/achievement_evaluator.dart';
import '../../domain/services/mindfulness_evaluator.dart';
import '../../services/analytics_service.dart';
import '../../services/haptics_service.dart';
import '../../services/sensors_service.dart';
import 'user_profile_provider.dart';

/// Причина, по которой Магический Шар отказывается отвечать —
/// см. FLUTTER_ARCHITECTURE_PLAN.md §5 (Этап 5) и задание Этапа 5.
enum MagicBallBlockReason { limitReached, lowEnergy }

/// Стоимость одного вопроса Шару в единицах `UserModel.magicBallEnergy`.
const int kMagicBallEnergyCost = 20;

/// Бесплатный пожизненный лимит вопросов (`UserModel.magicBallUses`).
const int kMagicBallFreeLimit = 20;

/// Порог `shakeIntensity`, после которого тряска телефона приравнивается к
/// нажатию кнопки "Спросить".
const double kMagicBallShakeThreshold = 0.7;

/// Неизменяемое состояние экрана Магического Шара.
class MagicBallState {
  const MagicBallState({
    this.answerText,
    this.isAsking = false,
    this.shakeIntensity = 0.0,
    this.blockReason,
  });

  /// Текст ответа на нужном языке; `null`, пока не спросили (или после
  /// [reset]).
  final String? answerText;

  /// Идёт короткая пауза-анимация "шар думает" перед показом ответа.
  final bool isAsking;

  /// 0.0-1.0 — текущая интенсивность тряски телефона, для визуальной
  /// реакции шара на экране (см. magic_ball_screen.dart).
  final double shakeIntensity;

  /// `null`, если вопрос разрешён; иначе причина блокировки (лимит/энергия).
  final MagicBallBlockReason? blockReason;

  MagicBallState copyWith({
    String? answerText,
    bool clearAnswerText = false,
    bool? isAsking,
    double? shakeIntensity,
    MagicBallBlockReason? blockReason,
    bool clearBlockReason = false,
  }) {
    return MagicBallState(
      answerText: clearAnswerText ? null : (answerText ?? this.answerText),
      isAsking: isAsking ?? this.isAsking,
      shakeIntensity: shakeIntensity ?? this.shakeIntensity,
      blockReason:
          clearBlockReason ? null : (blockReason ?? this.blockReason),
    );
  }
}

/// Riverpod-нотифаер экрана Магического Шара (Этап 5, см.
/// FLUTTER_ARCHITECTURE_PLAN.md §5). Инкапсулирует игровую логику (стоимость
/// вопроса, бесплатный лимит, подписка) и связывает её с UserProfileNotifier
/// (см. user_profile_provider.dart) — presentation-слой (MagicBallScreen)
/// вызывает только методы этого класса.
class MagicBallNotifier extends Notifier<MagicBallState> {
  /// Язык ответа — обновляется экраном на каждый build() из
  /// `Localizations.localeOf(context).languageCode` (см. задание, пункт E:
  /// НЕ `user.languageCode`, это поле пока нигде не обновляется). Нужен как
  /// запасное значение для случая, когда `ask()` вызывается неявно из
  /// тряски (см. [updateShakeIntensity]), а не по явному нажатию кнопки.
  String _languageCode = 'en';

  /// Момент начала текущей серии "слабой" тряски (выше шумового порога, но
  /// ниже [kMagicBallShakeThreshold]) — для секретной ачивки
  /// «Шёпот оракула» (`oracle_whisper`), см. [updateShakeIntensity].
  DateTime? _subThresholdShakeStart;

  @override
  MagicBallState build() => const MagicBallState();

  /// Вызывается экраном при каждом build() — держит [_languageCode] в
  /// актуальном состоянии для неявных вызовов [ask] из тряски.
  void setLanguageCode(String languageCode) {
    _languageCode = languageCode;
  }

  /// Обновляет [MagicBallState.shakeIntensity]. Если новое значение
  /// пересекает порог [kMagicBallShakeThreshold] и в этот момент НЕ идёт
  /// анимация ответа и нет ещё не сброшенного результата (свежий ответ или
  /// блокировка) — запускает тот же путь, что и нажатие кнопки [ask], чтобы
  /// тряска и кнопка вели к одному и тому же результату. Простая защита от
  /// повторных срабатываний: пока показан предыдущий ответ/блокировка,
  /// новые тряски не переспрашивают Шар — для этого нужно сначала [reset]
  /// (напр. явным нажатием кнопки "Спросить снова" или уходом с экрана).
  void updateShakeIntensity(double value) {
    // Секретная ачивка «Шёпот оракула» (`oracle_whisper`) — сустейн-тряска
    // 15+ секунд, которая НИКОГДА не пересекает основной порог (иначе она
    // автоматически превратится в обычный `ask()`). Слишком слабая тряска
    // (ниже шумового пола) или тряска, пересёкшая порог, прерывает серию.
    const double noiseFloor = 0.05;
    if (value > noiseFloor && value <= kMagicBallShakeThreshold) {
      _subThresholdShakeStart ??= DateTime.now();
      if (DateTime.now().difference(_subThresholdShakeStart!) >=
          const Duration(seconds: 15)) {
        _subThresholdShakeStart = null;
        // ignore: discarded_futures
        _unlockSecretAchievement('oracle_whisper');
      }
    } else {
      _subThresholdShakeStart = null;
    }

    state = state.copyWith(shakeIntensity: value);

    final bool hasPendingResult =
        state.answerText != null || state.blockReason != null;
    if (value > kMagicBallShakeThreshold && !state.isAsking && !hasPendingResult) {
      // Fire-and-forget: тряска не должна блокировать UI-поток ожиданием
      // Future, а результат придёт через state-обновления самого ask().
      // ignore: discarded_futures
      ask(_languageCode);
    }
  }

  /// Основной сценарий вопроса Шару — см. игровую логику в задании Этапа 5:
  ///  - подписчик (`user.isSubscribed`) -> всегда отвечает, энергия не
  ///    тратится, `magicBallUses` всё равно инкрементируется (для
  ///    статистики);
  ///  - НЕ подписчик, `magicBallUses >= kMagicBallFreeLimit` -> блокировка
  ///    `limitReached`;
  ///  - НЕ подписчик, `magicBallEnergy < kMagicBallEnergyCost` -> блокировка
  ///    `lowEnergy`;
  ///  - иначе -> списывает энергию, показывает случайный ответ.
  Future<void> ask(String languageCode) async {
    _languageCode = languageCode;

    // Уже идёт анимация ответа — повторный вызов игнорируем (защита от
    // двойного нажатия кнопки/повторной тряски, см. [updateShakeIntensity]).
    if (state.isAsking) return;

    final UserModel? user = ref.read(userProfileProvider);
    if (user == null) return;

    if (!user.isSubscribed) {
      if (user.magicBallUses >= kMagicBallFreeLimit) {
        state = state.copyWith(
          isAsking: false,
          blockReason: MagicBallBlockReason.limitReached,
        );
        return;
      }
      if (user.magicBallEnergy < kMagicBallEnergyCost) {
        state = state.copyWith(
          isAsking: false,
          blockReason: MagicBallBlockReason.lowEnergy,
        );
        return;
      }
    }

    state = state.copyWith(
      isAsking: true,
      clearAnswerText: true,
      clearBlockReason: true,
    );

    final HapticsService haptics = ref.read(hapticsServiceProvider);
    haptics.mediumTick();

    // Короткая пауза "шар думает" — см. ТЗ ("нарастает вибрация"): лёгкий
    // тик в начале, сильный — перед показом ответа.
    await Future<void>.delayed(const Duration(milliseconds: 800));

    haptics.strongTick();

    final Random random = Random();
    final MagicBallAnswerModel answer =
        MagicBallAnswerModel.all[random.nextInt(MagicBallAnswerModel.all.length)];
    final String text = answer.text(languageCode);

    await ref.read(userProfileProvider.notifier).updateProfile((current) {
      final int newUses = current.magicBallUses + 1;
      final DateTime now = DateTime.now();
      final bool sameDay = current.magicBallUsesTodayDate != null &&
          _isSameCalendarDay(current.magicBallUsesTodayDate!, now);
      final int newMagicBallUsesToday =
          sameDay ? current.magicBallUsesToday + 1 : 1;

      final UserModel intermediate;
      if (current.isSubscribed) {
        // Подписчик: только статистика, энергия не тратится.
        intermediate = current.copyWith(
          magicBallUses: newUses,
          magicBallUsesToday: newMagicBallUsesToday,
          magicBallUsesTodayDate: now,
          magicBallUsedDuringCurrentTagStreak: true,
        );
      } else {
        final int newEnergy =
            (current.magicBallEnergy - kMagicBallEnergyCost).clamp(0, 100);
        intermediate = current.copyWith(
          magicBallUses: newUses,
          magicBallEnergy: newEnergy,
          magicBallUsesToday: newMagicBallUsesToday,
          magicBallUsesTodayDate: now,
          magicBallUsedDuringCurrentTagStreak: true,
        );
      }

      final Set<String> newlyUnlocked =
          evaluateAchievementsOnMagicBallAsk(updatedUser: intermediate);
      if (newlyUnlocked.isEmpty) return intermediate;

      // Этап 9 — «Шкала осознанности»: +50/+150 очков за каждую только что
      // разблокированную ачивку (обычную/секретную), уровень не понижаем —
      // сравниваем с `current.mindfulnessLevel` (значение ДО этого мёржа).
      final Map<String, DateTime> merged = {...intermediate.achievements};
      int scoreDelta = 0;
      for (final String key in newlyUnlocked) {
        merged[key] = now;
        scoreDelta += mindfulnessPointsForAchievement(key);
      }

      final UserModel withScore = intermediate.copyWith(
        achievements: merged,
        mindfulnessScore: intermediate.mindfulnessScore + scoreDelta,
      );

      final MindfulnessLevel satisfiedLevel =
          computeSatisfiedMindfulnessLevel(withScore);
      final MindfulnessLevel finalLevel =
          satisfiedLevel.index > current.mindfulnessLevel.index
              ? satisfiedLevel
              : current.mindfulnessLevel;

      return withScore.copyWith(mindfulnessLevel: finalLevel);
    });

    // ignore: discarded_futures
    ref.read(analyticsServiceProvider).logMagicBallAsked();

    state = state.copyWith(isAsking: false, answerText: text);
  }

  /// Сбрасывает `answerText`/`blockReason` — вызывается перед повторным
  /// вопросом или при уходе с экрана (см. magic_ball_screen.dart, dispose()).
  void reset() {
    state = state.copyWith(clearAnswerText: true, clearBlockReason: true);
  }

  /// Засчитывает секретную ачивку [key] с текущей датой, если она ещё не
  /// получена. Используется для `oracle_whisper` (см.
  /// [updateShakeIntensity]) — не связана с обычным потоком `ask()`.
  Future<void> _unlockSecretAchievement(String key) async {
    await ref.read(userProfileProvider.notifier).updateProfile((current) {
      if (current.achievements.containsKey(key)) return current;

      // Этап 9 — те же +150 очков "Шкалы осознанности" и пересчёт уровня
      // (без понижения), что и в обычном пути мёржа ачивок внутри ask().
      final UserModel withAchievement = current.copyWith(
        achievements: {...current.achievements, key: DateTime.now()},
        mindfulnessScore:
            current.mindfulnessScore + mindfulnessPointsForAchievement(key),
      );

      final MindfulnessLevel satisfiedLevel =
          computeSatisfiedMindfulnessLevel(withAchievement);
      final MindfulnessLevel finalLevel =
          satisfiedLevel.index > current.mindfulnessLevel.index
              ? satisfiedLevel
              : current.mindfulnessLevel;

      return withAchievement.copyWith(mindfulnessLevel: finalLevel);
    });
  }
}

/// Сравнивает КАЛЕНДАРНУЮ дату (без времени) двух `DateTime` — тот же приём,
/// что и `_nextStreak` в `record_decision_completed.dart`.
bool _isSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

final NotifierProvider<MagicBallNotifier, MagicBallState> magicBallProvider =
    NotifierProvider<MagicBallNotifier, MagicBallState>(MagicBallNotifier.new);

/// Поток нормализованной интенсивности тряски (0.0-1.0) из
/// [sensorsServiceProvider] — экран подписывается на него через `ref.listen`
/// (см. magic_ball_screen.dart), StreamProvider сам отменяет подписку при
/// уходе с экрана вместе с жизненным циклом виджета/провайдера.
final StreamProvider<double> shakeIntensityStreamProvider =
    StreamProvider<double>((ref) {
  final SensorsService service = ref.watch(sensorsServiceProvider);
  return service.shakeIntensity;
});
