import '../../../data/models/decision_model.dart';
import '../../../data/models/location_model.dart';
import '../../../data/models/user_model.dart';
import '../../services/achievement_evaluator.dart';
import '../../services/mindfulness_evaluator.dart';

/// Usecase: пересчитывает профиль пользователя после только что завершённого
/// решения (кнопка «Решение принято» на экране «Принятие решения», см.
/// presentation/screens/decision_summary/decision_summary_screen.dart).
///
/// Обновляет ТОЛЬКО геймификационные поля, задокументированные для Этапа 4:
///  - `decisionsCount` — +1;
///  - `currentLocationIndex` — пересчитан через
///    `LocationModel.currentLocationIndexFor(newDecisionsCount)`;
///  - `streakDays`/`lastDecisionDate` — см. `_nextStreak` ниже;
///  - `magicBallEnergy` — восстанавливает +25 (не выше 100) за завершённое
///    решение, см. FLUTTER_ARCHITECTURE_PLAN.md §5 (Этап 5, "Магический
///    Шар") и задание Этапа 5, пункт D.
///
/// `achievements` — Этап 8a: после пересчёта геймификационных полей вызывает
/// `evaluateAchievementsOnDecisionCompleted` (см.
/// `lib/domain/services/achievement_evaluator.dart`) и мёржит в профиль
/// новые ключи ачивок с датой получения `DateTime.now()`.
///
/// `mindfulnessScore`/`mindfulnessLevel` — Этап 9: начисляет очки за решение
/// (и за только что разблокированные ачивки) и пересчитывает уровень через
/// `lib/domain/services/mindfulness_evaluator.dart`, никогда не понижая его.
class RecordDecisionCompleted {
  const RecordDecisionCompleted();

  UserModel call(UserModel user, DecisionModel completedDecision) {
    final int newDecisionsCount = user.decisionsCount + 1;
    final int newLocationIndex =
        LocationModel.currentLocationIndexFor(newDecisionsCount);
    final DateTime now = DateTime.now();
    final int newStreakDays = _nextStreak(user.lastDecisionDate, now, user.streakDays);

    // Серия одинаковых тегов подряд завершённых решений — для ачивок
    // «Парад планет»/«Идеальное выравнивание» (см. achievement_evaluator.dart).
    final String? tag = completedDecision.tag;
    final bool continuesStreak = tag != null && tag == user.lastDecisionTag;
    final int newSameTagStreak = tag == null
        ? user.sameTagStreak
        : (continuesStreak ? user.sameTagStreak + 1 : 1);
    final String? newLastDecisionTag = tag ?? user.lastDecisionTag;
    final bool newMagicBallUsedDuringStreak = tag == null
        ? user.magicBallUsedDuringCurrentTagStreak
        : (continuesStreak ? user.magicBallUsedDuringCurrentTagStreak : false);

    final UserModel updated = user.copyWith(
      decisionsCount: newDecisionsCount,
      currentLocationIndex: newLocationIndex,
      streakDays: newStreakDays,
      lastDecisionDate: now,
      magicBallEnergy: (user.magicBallEnergy + 25).clamp(0, 100),
      sameTagStreak: newSameTagStreak,
      lastDecisionTag: newLastDecisionTag,
      magicBallUsedDuringCurrentTagStreak: newMagicBallUsedDuringStreak,
    );

    final Set<String> newlyUnlocked = evaluateAchievementsOnDecisionCompleted(
      previousUser: user,
      updatedUser: updated,
      completedDecision: completedDecision,
    );

    // Этап 9 — «Шкала осознанности»: +10 (базово) / +35 (развёрнутое решение)
    // за само решение, плюс +50/+150 за каждую только что разблокированную
    // ачивку (обычную/секретную), см. domain/services/mindfulness_evaluator.dart.
    int scoreDelta = mindfulnessPointsForDecision(completedDecision);
    for (final String key in newlyUnlocked) {
      scoreDelta += mindfulnessPointsForAchievement(key);
    }

    final Map<String, DateTime> merged = {...updated.achievements};
    for (final String key in newlyUnlocked) {
      merged[key] = now;
    }

    final UserModel withScore = updated.copyWith(
      achievements: merged,
      mindfulnessScore: updated.mindfulnessScore + scoreDelta,
    );

    // Уровень никогда не понижается — сравниваем удовлетворённый прямо
    // сейчас уровень с уровнем, который был у пользователя ДО этого вызова.
    final MindfulnessLevel satisfiedLevel =
        computeSatisfiedMindfulnessLevel(withScore);
    final MindfulnessLevel finalLevel =
        satisfiedLevel.index > user.mindfulnessLevel.index
            ? satisfiedLevel
            : user.mindfulnessLevel;

    return withScore.copyWith(mindfulnessLevel: finalLevel);
  }

  /// Сравнивает КАЛЕНДАРНУЮ дату (без времени) `lastDecisionDate` и «сегодня»:
  ///  - `lastDecisionDate` был вчера относительно сегодня -> streak + 1;
  ///  - `lastDecisionDate` уже сегодня (повторное решение в тот же день) ->
  ///    streak не меняется;
  ///  - иначе (пропуск дня(-ей) или первое решение вообще, `lastDecisionDate`
  ///    == null) -> streak сбрасывается на 1.
  int _nextStreak(DateTime? lastDecisionDate, DateTime now, int currentStreak) {
    if (lastDecisionDate == null) return 1;

    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime lastDay = DateTime(
      lastDecisionDate.year,
      lastDecisionDate.month,
      lastDecisionDate.day,
    );
    final int dayDifference = today.difference(lastDay).inDays;

    if (dayDifference == 0) return currentStreak;
    if (dayDifference == 1) return currentStreak + 1;
    return 1;
  }
}
