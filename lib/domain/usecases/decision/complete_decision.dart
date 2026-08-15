import '../../../data/models/decision_model.dart';
import '../../repositories/decision_repository.dart';

/// Usecase: завершить решение (кнопка «Решение принято» на экране
/// «Принятие решения» — см.
/// presentation/screens/decision_summary/decision_summary_screen.dart).
/// Ожидает [DecisionModel] уже с `status: DecisionStatus.completed`,
/// `completedAt` и `draftToCompleteSeconds`, выставленными вызывающей
/// стороной (см. комментарий в decision_summary_screen.dart).
class CompleteDecision {
  const CompleteDecision(this._repository);

  final DecisionRepository _repository;

  Future<void> call(DecisionModel decision) =>
      _repository.completeDecision(decision);
}
