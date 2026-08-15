import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/decision_repository.dart';
import '../datasources/local/hive_decisions_datasource.dart';
import '../datasources/remote/firestore_decisions_datasource.dart';
import '../models/decision_model.dart';

/// Реализация [DecisionRepository].
///
/// MVP-паттерн синхронизации (Этап 3, задокументировано явно здесь по
/// требованию задания): Hive — единственный источник истины, используется
/// офлайн и для анонимных пользователей, запись в него происходит первой и
/// её результат — то, что возвращает метод репозитория. Firestore — это
/// ДОПОЛНИТЕЛЬНАЯ, best-effort попытка синхронизации, которая:
///  - вызывается ПОСЛЕ успешной записи в Hive;
///  - всегда обёрнута в try/catch на этом уровне (двойная защита — сам
///    [FirestoreDecisionsDatasource] тоже ловит свои исключения, см. его
///    комментарий, но здесь дублируем try/catch, чтобы инвариант «Firestore
///    никогда не ломает основной путь» не зависел от будущих правок
///    датасорса);
///  - её результат/ошибка НИКОГДА не влияют на результат вызова
///    saveDraft/completeDecision — если Firebase не настроен
///    (flutterfire configure ещё не выполнялся, см. main.dart) или недоступна
///    сеть, приложение продолжает работать полностью на Hive, просто без
///    облачного бэкапа.
class DecisionRepositoryImpl implements DecisionRepository {
  const DecisionRepositoryImpl(this._localDatasource, this._remoteDatasource);

  final HiveDecisionsDatasource _localDatasource;
  final FirestoreDecisionsDatasource _remoteDatasource;

  @override
  Future<void> saveDraft(DecisionModel decision) async {
    await _localDatasource.saveDraft(decision);
    await _tryMirrorToFirestore(decision);
  }

  @override
  DecisionModel? getDraft(String id) => _localDatasource.getDraft(id);

  @override
  Future<void> deleteDraft(String id) => _localDatasource.deleteDraft(id);

  @override
  List<DecisionModel> getAllDrafts(String userId) =>
      _localDatasource.getAllDrafts(userId);

  @override
  Future<void> completeDecision(DecisionModel decision) async {
    await _localDatasource.saveDraft(decision);
    await _tryMirrorToFirestore(decision);
  }

  /// Best-effort зеркалирование в Firestore — см. комментарий класса.
  Future<void> _tryMirrorToFirestore(DecisionModel decision) async {
    try {
      await _remoteDatasource.saveDecision(decision);
    } catch (_) {
      // Не должно случиться (датасорс сам ловит все свои исключения), но
      // подстраховываемся здесь тоже — синк в Firestore никогда не должен
      // ломать основной (Hive) путь сохранения.
    }
  }
}

final Provider<DecisionRepository> decisionRepositoryProvider =
    Provider<DecisionRepository>((ref) {
  return DecisionRepositoryImpl(
    ref.watch(hiveDecisionsDatasourceProvider),
    ref.watch(firestoreDecisionsDatasourceProvider),
  );
});
