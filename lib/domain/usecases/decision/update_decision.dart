import '../../../data/models/decision_model.dart';
import '../../repositories/decision_repository.dart';

/// Usecase: обновить уже существующий черновик/решение (последующие
/// автосохранения при вводе текста — см.
/// presentation/providers/decision_flow_provider.dart).
class UpdateDecision {
  const UpdateDecision(this._repository);

  final DecisionRepository _repository;

  Future<void> call(DecisionModel decision) => _repository.saveDraft(decision);
}
