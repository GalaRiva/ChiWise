import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_model.dart';

/// Удалённый (Firestore) источник данных для профиля пользователя — CRUD по
/// ОДНОМУ документу `users/{uid}` (не коллекции), см.
/// FLUTTER_ARCHITECTURE_PLAN.md §2.1. Использует `UserModel.toJson()/fromJson()`
/// как есть — они уже рассчитаны на `cloud_firestore.Timestamp`.
///
/// Тот же паттерн ловушки, что задокументирован в auth_provider.dart и
/// firestore_decisions_datasource.dart: `FirebaseFirestore.instance` бросает
/// синхронное исключение, если `Firebase.initializeApp()` ещё не вызван.
/// Конструктор `FirestoreUserDatasource()` ничего не трогает в Firebase —
/// ловушка обёрнута в КАЖДЫЙ публичный метод по отдельности:
///  - `getUser` при любой ошибке возвращает null;
///  - `saveUser` при любой ошибке молча завершается (Future<void> без
///    исключения наружу).
///
/// Итоговое поведение для вызывающего кода (UserRepositoryImpl): методы
/// этого датасорса можно звать без собственного try/catch — пока Firebase не
/// настроен (или недоступна сеть/нет прав), Firestore-часть молча ничего не
/// делает, а приложение продолжает работать полностью на Hive.
class FirestoreUserDatasource {
  const FirestoreUserDatasource();

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  /// Возвращает профиль пользователя или null, если документа нет либо
  /// Firestore/Firebase недоступны.
  Future<UserModel?> getUser(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _userDoc(uid).get();
      final Map<String, dynamic>? data = snapshot.data();
      if (data == null) return null;
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Создаёт/перезаписывает документ профиля. Молча ничего не делает при
  /// любой ошибке (Firebase не инициализирован, нет сети, нет прав и т.д.) —
  /// см. комментарий класса.
  Future<void> saveUser(UserModel user) async {
    try {
      await _userDoc(user.id).set(user.toJson());
    } catch (_) {
      // Best-effort синк — намеренно проглатываем любую ошибку, см.
      // комментарий класса.
    }
  }

  /// Удаляет документ профиля. Молча ничего не делает при любой ошибке.
  Future<void> deleteUser(String uid) async {
    try {
      await _userDoc(uid).delete();
    } catch (_) {
      // См. комментарий класса.
    }
  }
}

/// Провайдер датасорса. Конструктор `FirestoreUserDatasource()` ничего не
/// трогает в Firebase (см. комментарий класса), поэтому провайдер не
/// нуждается в try/catch — вся защита находится внутри методов датасорса.
final Provider<FirestoreUserDatasource> firestoreUserDatasourceProvider =
    Provider<FirestoreUserDatasource>((ref) {
  return const FirestoreUserDatasource();
});
