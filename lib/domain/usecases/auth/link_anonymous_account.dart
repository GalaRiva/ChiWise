import '../../../data/models/user_model.dart';
import '../../repositories/auth_repository.dart';

/// Usecase: привязка Google/Apple к текущему анонимному аккаунту без потери
/// данных (account linking, см. AuthRepository.linkAnonymousAccount).
class LinkAnonymousAccount {
  const LinkAnonymousAccount(this._repository);

  final AuthRepository _repository;

  Future<String> call(AuthProviderType provider) =>
      _repository.linkAnonymousAccount(provider);
}
