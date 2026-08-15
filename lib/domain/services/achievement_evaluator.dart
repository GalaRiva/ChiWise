import '../../data/models/decision_model.dart';
import '../../data/models/user_model.dart';

/// Чистая (без побочных эффектов) логика расчёта условий всех 13 ачивок
/// (см. `lib/data/models/achievement_model.dart` — `AchievementModel.all`).
///
/// Обе функции ничего не пишут в профиль и не сохраняют результат — они
/// только ВОЗВРАЩАЮТ множество ключей ачивок, которые нужно засчитать прямо
/// сейчас. Мёрж в `UserModel.achievements` (с проставлением даты получения)
/// делает вызывающий код:
///  - `RecordDecisionCompleted` (после завершения решения) —
///    см. `lib/domain/usecases/gamification/record_decision_completed.dart`;
///  - `MagicBallNotifier.ask()` (после обращения к Магическому Шару) —
///    см. `lib/presentation/providers/magic_ball_provider.dart`.
///
/// Секретная ачивка `oracle_whisper` сюда НЕ входит — она зависит от
/// длительности жеста тряски в реальном времени (не от пересчёта профиля) и
/// реализована отдельно, напрямую внутри `MagicBallNotifier`.

/// Вызывается после того, как решение переведено в статус `completed` и
/// профиль пересчитан (`decisionsCount`/`currentLocationIndex`/
/// `streakDays`/`magicBallEnergy`/`sameTagStreak`/
/// `magicBallUsedDuringCurrentTagStreak` — уже готовы в [updatedUser]).
///
/// [previousUser] — профиль ДО пересчёта гамификации в этом решении, нужен
/// для сравнения "было/стало" (напр. `currentLocationIndex` для
/// `light_mind`).
Set<String> evaluateAchievementsOnDecisionCompleted({
  required UserModel previousUser,
  required UserModel updatedUser,
  required DecisionModel completedDecision,
}) {
  final Set<String> unlocked = {};

  final int q1 = completedDecision.argumentCounts['q1'] ?? 0;
  final int q2 = completedDecision.argumentCounts['q2'] ?? 0;
  final int q3 = completedDecision.argumentCounts['q3'] ?? 0;
  final int q4 = completedDecision.argumentCounts['q4'] ?? 0;

  // «Орбитальная стабильность» — 7 дней подряд с решениями.
  if (updatedUser.streakDays >= 7) {
    unlocked.add('orbital_stability');
  }

  // «Ночной мудрец совы» — решение завершено после 23:00.
  if (completedDecision.completedAt != null &&
      completedDecision.completedAt!.hour >= 23) {
    unlocked.add('night_owl_sage');
  }

  // «Мастер баланса» — все 4 блока заполнены (>0) и равны друг другу.
  if (q1 > 0 && q1 == q2 && q2 == q3 && q3 == q4) {
    unlocked.add('balance_master');
  }

  // «Глубокий анализ» — все 4 блока строго больше 5.
  if (q1 > 5 && q2 > 5 && q3 > 5 && q4 > 5) {
    unlocked.add('deep_analysis');
  }

  // «Разрушитель иллюзий» — блок «Чего НЕ будет, если это НЕ произойдёт»
  // (q4) строго больше каждого из остальных трёх.
  if (q4 > q1 && q4 > q2 && q4 > q3) {
    unlocked.add('illusion_breaker');
  }

  // «Высота Орхехии» (секретная) — все 4 блока заполнены (>0) и ни разу не
  // был нажат backspace/delete при заполнении.
  if (q1 > 0 && q2 > 0 && q3 > 0 && q4 > 0 && !completedDecision.usedBackspace) {
    unlocked.add('orhekia_height');
  }

  // «Ловец затмения» — черновик "провисел" 7+ дней до завершения.
  final int? draftSeconds = completedDecision.draftToCompleteSeconds;
  if (draftSeconds != null && draftSeconds >= 7 * 24 * 3600) {
    unlocked.add('eclipse_catcher');
  }

  // «Наблюдатель затмения» (секретная) — решение открытого вопроса ТЗ о
  // пересечении с `eclipse_catcher`: секретная версия требует ВДВОЕ более
  // долгого «зависания» черновика (14 дней), чем обычная (7 дней), поэтому
  // при достижении 14 дней засчитываются ОБЕ ачивки одновременно.
  if (draftSeconds != null && draftSeconds >= 14 * 24 * 3600) {
    unlocked.add('eclipse_observer');
  }

  // «Парад планет» и «Идеальное выравнивание» (секретная) зависят от
  // `DecisionModel.tag`, который сейчас нигде не устанавливается UI (нет
  // экрана выбора категории — появится в Этапе 10 при работе над bubble
  // chart). Поэтому обе ачивки физически не смогут сработать, пока такой UI
  // не появится, но логика уже полностью готова и сработает автоматически,
  // как только `tag` начнёт приходить непустым.
  if (updatedUser.sameTagStreak >= 6) {
    unlocked.add('planet_parade');
    if (!updatedUser.magicBallUsedDuringCurrentTagStreak) {
      unlocked.add('perfect_alignment');
    }
  }

  // «Лёгкий разум» — прагматичная трактовка неоднозначной формулировки ТЗ
  // («переход с земных локаций на космические»): локации открываются строго
  // последовательно по числу решений, поэтому «переход» означает «впервые
  // достигнут индекс локации Звёздный пик (2) или дальше».
  if (previousUser.currentLocationIndex < 2 &&
      updatedUser.currentLocationIndex >= 2) {
    unlocked.add('light_mind');
  }

  // «Магический резонанс» — энергия Шара на максимуме, при этом Шаром ещё ни
  // разу не пользовались.
  if (updatedUser.magicBallEnergy >= 100 && updatedUser.magicBallUses == 0) {
    unlocked.add('magic_resonance');
  }

  // Не пере-выдаём уже полученные ачивки.
  unlocked.removeWhere(updatedUser.achievements.containsKey);
  return unlocked;
}

/// Вызывается после обращения к Магическому Шару (см.
/// `MagicBallNotifier.ask()`), когда `magicBallUsesToday` в [updatedUser]
/// уже пересчитан на актуальный календарный день.
Set<String> evaluateAchievementsOnMagicBallAsk({
  required UserModel updatedUser,
}) {
  final Set<String> unlocked = {};

  // «Испытатель судьбы» — упрощение относительно формулировки ТЗ («для
  // разных вопросов»): Магический Шар в этом приложении не принимает текст
  // вопроса от пользователя (нет соответствующего поля ввода), поэтому
  // «разные вопросы» технически неотличимы друг от друга. Условие упрощено
  // до «3 обращения к Шару за один календарный день».
  if (updatedUser.magicBallUsesToday >= 3) {
    unlocked.add('fate_tester');
  }

  unlocked.removeWhere(updatedUser.achievements.containsKey);
  return unlocked;
}
