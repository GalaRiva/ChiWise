import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/user_repository.dart';
import '../datasources/local/hive_user_datasource.dart';
import '../datasources/remote/firestore_user_datasource.dart';
import '../models/user_model.dart';

/// Реализация [UserRepository] — точная копия паттерна
/// DecisionRepositoryImpl (см. lib/data/repositories/decision_repository_impl.dart,
/// комментарий там детально документирует инвариант, здесь дублируем кратко):
/// Hive — источник истины, используется для чтения и как результат записи;
/// Firestore — ДОПОЛНИТЕЛЬНАЯ, best-effort попытка синхронизации, которая
/// вызывается ПОСЛЕ успешной записи в Hive, обёрнута в try/catch на этом
/// уровне (двойная защита поверх собственного try/catch датасорса) и никогда
/// не влияет на результат вызова saveUser — если Firebase не настроен или
/// недоступна сеть, приложение продолжает работать полностью на Hive.
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._localDatasource, this._remoteDatasource);

  final HiveUserDatasource _localDatasource;
  final FirestoreUserDatasource _remoteDatasource;

  @override
  UserModel? getUser(String uid) => _localDatasource.getUser(uid);

  @override
  Future<void> saveUser(UserModel user) async {
    await _localDatasource.saveUser(user);
    await _tryMirrorToFirestore(user);
  }

  /// Best-effort зеркалирование в Firestore — см. комментарий класса.
  Future<void> _tryMirrorToFirestore(UserModel user) async {
    try {
      await _remoteDatasource.saveUser(user);
    } catch (_) {
      // Не должно случиться (датасорс сам ловит все свои исключения), но
      // подстраховываемся здесь тоже — синк в Firestore никогда не должен
      // ломать основной (Hive) путь сохранения.
    }
  }
}

final Provider<UserRepository> userRepositoryProvider =
    Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    ref.watch(hiveUserDatasourceProvider),
    ref.watch(firestoreUserDatasourceProvider),
  );
});
