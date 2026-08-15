import '../../core/localization/generated/app_localizations.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/decision_model.dart';
import '../../data/models/user_model.dart';

/// Чистые (без побочных эффектов) функции для «Шкалы осознанности»
/// (`UserModel.mindfulnessScore`/`mindfulnessLevel`), см.
/// FLUTTER_ARCHITECTURE_PLAN.md §4. Побочные эффекты (запись обновлённого
/// UserModel) — в вызывающем коде: `RecordDecisionCompleted` usecase и
/// `MagicBallNotifier` (Этап 9).

/// Порог "развёрнутого" решения — заполнялось 2-3+ минуты, см. задание
/// Этапа 9 и FLUTTER_ARCHITECTURE_PLAN.md §4.
const int kMindfulnessExpandedDecisionThresholdSeconds = 150;

/// Базовые очки за любое завершённое решение.
const int kMindfulnessPointsPerDecision = 10;

/// Дополнительные очки за "развёрнутое" решение (сверх базовых).
const int kMindfulnessPointsExpandedDecisionBonus = 25;

/// Очки за обычную (не секретную) ачивку.
const int kMindfulnessPointsRegularAchievement = 50;

/// Очки за секретную ачивку.
const int kMindfulnessPointsSecretAchievement = 150;

/// Сколько завершённых решений нужно для уровня `observer`.
const int kMindfulnessObserverDecisionsThreshold = 5;

/// Сколько дней подряд (`UserModel.streakDays`) нужно для уровня
/// `rationalist`. Допущение: «несколько дней подряд» из ТЗ трактуется как
/// 3 дня — точное число нигде в ТЗ не зафиксировано явно, выбрано разработчиком
/// как разумный минимум для "нескольких".
const int kMindfulnessRationalistStreakThreshold = 3;

/// Индекс последней (16-й, 0-based 15) локации маршрута — условие уровня
/// `guardianOfClarity` (пройден весь маршрут), см.
/// `LocationModel.locations.length == 16`.
const int kMindfulnessGuardianLocationIndex = 15;

/// Очки за завершённое решение (+10 всегда, +25 доп. если "развёрнутое",
/// т.е. `draftToCompleteSeconds >= 150`). Если `draftToCompleteSeconds ==
/// null` — бонус не начисляется.
int mindfulnessPointsForDecision(DecisionModel decision) {
  int points = kMindfulnessPointsPerDecision;
  final int? seconds = decision.draftToCompleteSeconds;
  if (seconds != null && seconds >= kMindfulnessExpandedDecisionThresholdSeconds) {
    points += kMindfulnessPointsExpandedDecisionBonus;
  }
  return points;
}

/// Очки за одну разблокированную ачивку по её ключу (+50 обычная / +150
/// секретная). Если ачивка с таким ключом не найдена в
/// `AchievementModel.all` — возвращает 0 (защита от опечатки, не должно
/// происходить в норме).
int mindfulnessPointsForAchievement(String achievementKey) {
  for (final AchievementModel achievement in AchievementModel.all) {
    if (achievement.key == achievementKey) {
      return achievement.isSecret
          ? kMindfulnessPointsSecretAchievement
          : kMindfulnessPointsRegularAchievement;
    }
  }
  return 0;
}

/// Самый высокий уровень, условию которого удовлетворяет ТЕКУЩЕЕ состояние
/// [user] (см. 5 условий в FLUTTER_ARCHITECTURE_PLAN.md §4). НЕ учитывает
/// историю/предыдущий уровень — вызывающий код сам берёт
/// max(текущий сохранённый уровень, результат этой функции) по индексу enum,
/// чтобы не понижать уровень пользователя (см. RecordDecisionCompleted,
/// MagicBallNotifier).
MindfulnessLevel computeSatisfiedMindfulnessLevel(UserModel user) {
  final bool hasSecretAchievement = user.achievements.keys.any(
    (String key) => AchievementModel.all
        .where((AchievementModel a) => a.isSecret)
        .map((AchievementModel a) => a.key)
        .contains(key),
  );

  if (user.currentLocationIndex >= kMindfulnessGuardianLocationIndex) {
    return MindfulnessLevel.guardianOfClarity;
  }
  if (hasSecretAchievement) {
    return MindfulnessLevel.balanceMaster;
  }
  if (user.streakDays >= kMindfulnessRationalistStreakThreshold) {
    return MindfulnessLevel.rationalist;
  }
  if (user.decisionsCount >= kMindfulnessObserverDecisionsThreshold) {
    return MindfulnessLevel.observer;
  }
  return MindfulnessLevel.seeker;
}

/// 0.0..1.0 — прогресс к СЛЕДУЮЩЕМУ уровню относительно
/// [user.mindfulnessLevel] (текущего СОХРАНЁННОГО уровня, не пересчитанного
/// через [computeSatisfiedMindfulnessLevel]). Для `guardianOfClarity`
/// (максимальный уровень) возвращает 1.0.
double mindfulnessProgressToNextLevel(UserModel user) {
  switch (user.mindfulnessLevel) {
    case MindfulnessLevel.seeker:
      // Следующий уровень — observer.
      return (user.decisionsCount / kMindfulnessObserverDecisionsThreshold)
          .clamp(0.0, 1.0);
    case MindfulnessLevel.observer:
      // Следующий уровень — rationalist.
      return (user.streakDays / kMindfulnessRationalistStreakThreshold)
          .clamp(0.0, 1.0);
    case MindfulnessLevel.rationalist:
      // Следующий уровень — balanceMaster: условие бинарное (есть/нет
      // секретная ачивка).
      final bool hasSecretAchievement = user.achievements.keys.any(
        (String key) => AchievementModel.all
            .where((AchievementModel a) => a.isSecret)
            .map((AchievementModel a) => a.key)
            .contains(key),
      );
      return hasSecretAchievement ? 1.0 : 0.0;
    case MindfulnessLevel.balanceMaster:
      // Следующий уровень — guardianOfClarity.
      return (user.currentLocationIndex / kMindfulnessGuardianLocationIndex)
          .clamp(0.0, 1.0);
    case MindfulnessLevel.guardianOfClarity:
      return 1.0;
  }
}

/// Локализованное имя уровня — общая функция, используется на экране
/// «Шкала осознанности» (mindfulness_screen.dart) и в снэкбаре повышения
/// уровня на decision_summary_screen.dart (см. задание Этапа 9, Задача 8).
String mindfulnessLevelName(AppLocalizations l10n, MindfulnessLevel level) {
  switch (level) {
    case MindfulnessLevel.seeker:
      return l10n.mindfulnessLevelSeeker;
    case MindfulnessLevel.observer:
      return l10n.mindfulnessLevelObserver;
    case MindfulnessLevel.rationalist:
      return l10n.mindfulnessLevelRationalist;
    case MindfulnessLevel.balanceMaster:
      return l10n.mindfulnessLevelBalanceMaster;
    case MindfulnessLevel.guardianOfClarity:
      return l10n.mindfulnessLevelGuardianOfClarity;
  }
}
