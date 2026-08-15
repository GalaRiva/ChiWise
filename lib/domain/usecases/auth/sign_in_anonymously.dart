import '../../repositories/auth_repository.dart';

/// Usecase: «Продолжить без регистрации» (Firebase Anonymous Auth).
class SignInAnonymously {
  const SignInAnonymously(this._repository);

  final AuthRepository _repository;

  Future<String> call() => _repository.signInAnonymously();
}
