import '../../data/models/decision_model.dart';

/// Абстракция репозитория решений (Clean Architecture, domain-уровень).
///
/// Этап 3: реализация (см. lib/data/repositories/decision_repository_impl.dart)
/// остаётся Hive-first (источник истины офлайн и для анонимных пользователей),
/// но дополнительно делает best-effort синхронизацию каждой записи в
/// Firestore — см. подробный комментарий в реализации и в
/// firestore_decisions_datasource.dart.
///
/// TODO(будущий этап): перенос анонимных черновиков при регистрации —
/// репозиторий должен будет мёржить локальный Hive-кэш и удалённые данные,
/// не меняя эту сигнатуру.
abstract class DecisionRepository {
  Future<void> saveDraft(DecisionModel decision);

  DecisionModel? getDraft(String id);

  Future<void> deleteDraft(String id);

  List<DecisionModel> getAllDrafts(String userId);

  /// Завершает решение: сохраняет запись со `status: DecisionStatus.completed`
  /// (Hive — всегда, Firestore — best-effort). Вызывается из
  /// DecisionSummaryScreen после нажатия «Решение принято» (см.
  /// lib/presentation/screens/decision_summary/decision_summary_screen.dart).
  Future<void> completeDecision(DecisionModel decision);
}
