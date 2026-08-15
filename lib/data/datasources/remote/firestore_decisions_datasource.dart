import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/decision_model.dart';

/// Удалённый (Firestore) источник данных для решений — CRUD по пути
/// `users/{uid}/decisions/{decisionId}`, см. FLUTTER_ARCHITECTURE_PLAN.md §2.2.
/// Использует `DecisionModel.toJson()/fromJson()` как есть — они уже
/// рассчитаны на `cloud_firestore.Timestamp`, адаптация не нужна (в отличие
/// от HiveDecisionsDatasource, который сознательно их не использует — см.
/// комментарий там).
///
/// ВАЖНО — тот же паттерн ловушки, что уже описан в auth_provider.dart для
/// `FirebaseAuth.instance`: `FirebaseFirestore.instance` бросает синхронное
/// исключение, если `Firebase.initializeApp()` ещё не вызван (сейчас
/// закомментировано в main.dart до `flutterfire configure`). Здесь эта
/// ловушка обёрнута НЕ в конструктор (конструктор ничего не трогает в
/// Firebase — можно безопасно создавать датасорс/провайдер в любой момент),
/// а в КАЖДЫЙ публичный метод по отдельности:
///  - read-методы (getDecision/getAllDecisions) при любой ошибке возвращают
///    null / пустой список;
///  - write-методы (saveDecision/deleteDecision) при любой ошибке просто
///    молча завершаются (Future<void> без исключения наружу).
///
/// Итоговое поведение для вызывающего кода (DecisionRepositoryImpl): методы
/// этого датасорса можно звать без собственного try/catch — пока Firebase не
/// настроен (или недоступна сеть/нет прав), Firestore-часть молча ничего не
/// делает, а приложение продолжает работать полностью на Hive.
class FirestoreDecisionsDatasource {
  const FirestoreDecisionsDatasource();

  CollectionReference<Map<String, dynamic>> _decisionsCollection(
    String userId,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('decisions');
  }

  /// Создаёт/перезаписывает документ решения. Молча ничего не делает при
  /// любой ошибке (Firebase не инициализирован, нет сети, нет прав и т.д.) —
  /// см. комментарий класса.
  Future<void> saveDecision(DecisionModel decision) async {
    try {
      await _decisionsCollection(decision.userId)
          .doc(decision.id)
          .set(decision.toJson());
    } catch (_) {
      // Best-effort синк — намеренно проглатываем любую ошибку, см.
      // комментарий класса.
    }
  }

  /// Возвращает решение по id или null, если документа нет либо
  /// Firestore/Firebase недоступны.
  Future<DecisionModel?> getDecision(String userId, String id) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _decisionsCollection(userId).doc(id).get();
      final Map<String, dynamic>? data = snapshot.data();
      if (data == null) return null;
      return DecisionModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Удаляет документ решения. Молча ничего не делает при любой ошибке.
  Future<void> deleteDecision(String userId, String id) async {
    try {
      await _decisionsCollection(userId).doc(id).delete();
    } catch (_) {
      // См. комментарий класса.
    }
  }

  /// Возвращает все решения пользователя либо пустой список при любой ошибке.
  Future<List<DecisionModel>> getAllDecisions(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _decisionsCollection(userId).get();
      return snapshot.docs
          .map((doc) => DecisionModel.fromJson(doc.data()))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

/// Провайдер датасорса. Конструктор `FirestoreDecisionsDatasource()` ничего
/// не трогает в Firebase (см. комментарий класса), поэтому в отличие от
/// `authRepositoryProvider` (auth_provider.dart) этот провайдер не нуждается
/// в try/catch — вся защита находится внутри методов датасорса.
final Provider<FirestoreDecisionsDatasource>
    firestoreDecisionsDatasourceProvider =
    Provider<FirestoreDecisionsDatasource>((ref) {
  return const FirestoreDecisionsDatasource();
});
