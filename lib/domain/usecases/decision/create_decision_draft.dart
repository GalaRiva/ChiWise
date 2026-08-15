import '../../../data/models/decision_model.dart';
import '../../repositories/decision_repository.dart';

/// Usecase: создать новый черновик решения (первое сохранение в Hive —
/// см. DecisionFlowNotifier._persist в presentation/providers/decision_flow_provider.dart).
class CreateDecisionDraft {
  const CreateDecisionDraft(this._repository);

  final DecisionRepository _repository;

  Future<void> call(DecisionModel decision) => _repository.saveDraft(decision);
}
