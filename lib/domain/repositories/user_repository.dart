import '../../data/models/user_model.dart';

/// Абстракция репозитория профиля пользователя (Clean Architecture,
/// domain-уровень). Тот же принцип, что и DecisionRepository (Этап 3): Hive —
/// источник истины (офлайн и для анонимных пользователей), реализация
/// (см. lib/data/repositories/user_repository_impl.dart) дополнительно делает
/// best-effort синхронизацию в Firestore.
abstract class UserRepository {
  UserModel? getUser(String uid);

  Future<void> saveUser(UserModel user);

  /// Удаляет профиль (Hive + Firestore) — используется при удалении
  /// аккаунта, см. DeleteAccount usecase.
  Future<void> deleteUser(String uid);
}
