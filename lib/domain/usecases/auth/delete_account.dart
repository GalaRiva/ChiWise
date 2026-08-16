import '../../repositories/auth_repository.dart';
import '../../repositories/decision_repository.dart';
import '../../repositories/user_repository.dart';

/// Usecase: полное удаление аккаунта (Настройки -> "Удалить аккаунт").
/// Порядок вызовов важен: данные удаляются, ПОКА пользователь ещё
/// аутентифицирован (иначе Firestore Security Rules — `request.auth.uid ==
/// userId` — отклонят удаление), и только в конце удаляется сам аккаунт
/// Firebase Auth.
class DeleteAccount {
  const DeleteAccount(
    this._authRepository,
    this._userRepository,
    this._decisionRepository,
  );

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final DecisionRepository _decisionRepository;

  Future<void> call(String uid) async {
    await _decisionRepository.deleteAllForUser(uid);
    await _userRepository.deleteUser(uid);
    await _authRepository.deleteAccount();
  }
}
