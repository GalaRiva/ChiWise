import '../../repositories/auth_repository.dart';

/// Usecase: вход через Google. Тонкая обёртка над репозиторием — presentation-слой
/// (AuthNotifier) дёргает usecases, а не репозиторий напрямую (Clean Architecture).
class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<String> call() => _repository.signInWithGoogle();
}
