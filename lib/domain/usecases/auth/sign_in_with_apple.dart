import '../../repositories/auth_repository.dart';

/// Usecase: вход через Apple. Тонкая обёртка над репозиторием — presentation-слой
/// (AuthNotifier) дёргает usecases, а не репозиторий напрямую (Clean Architecture).
class SignInWithApple {
  const SignInWithApple(this._repository);

  final AuthRepository _repository;

  Future<String> call() => _repository.signInWithApple();
}
