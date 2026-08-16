import '../../data/models/user_model.dart';

/// Абстракция слоя авторизации (Clean Architecture, domain-уровень).
/// Реализация — lib/data/repositories/auth_repository_impl.dart (firebase_auth
/// + google_sign_in + sign_in_with_apple).
///
/// Важно (требование ТЗ): при переходе от анонимного аккаунта к
/// зарегистрированному (Google/Apple) данные пользователя не должны
/// теряться. Для этого используется account linking —
/// `linkAnonymousAccount` вызывает `FirebaseAuth.currentUser.linkWithCredential`,
/// а НЕ `signOut()` + повторный `signIn()`, который создал бы новый uid.
abstract class AuthRepository {
  /// uid текущего пользователя Firebase Auth, либо null, если никто не вошёл.
  String? get currentUserId;

  /// Способ входа текущего пользователя (google/apple/anonymous), либо null,
  /// если пользователь не авторизован.
  AuthProviderType? get currentAuthProvider;

  /// Поток изменений текущего пользователя: эмитит uid при входе/линковке,
  /// null — при выходе. Источник истины для presentation-слоя.
  Stream<String?> authStateChanges();

  /// Вход через Google (создаёт новую Firebase-сессию, НЕ анонимную).
  Future<String> signInWithGoogle();

  /// Вход через Apple (создаёт новую Firebase-сессию, НЕ анонимную).
  Future<String> signInWithApple();

  /// «Продолжить без регистрации» — Firebase Anonymous Auth.
  Future<String> signInAnonymously();

  /// Привязывает Google/Apple credential к уже существующему анонимному
  /// аккаунту, сохраняя uid и все связанные с ним данные (черновики решений,
  /// прогресс и т.д.) — см. описание класса выше.
  Future<String> linkAnonymousAccount(AuthProviderType provider);

  Future<void> signOut();

  /// Удаляет ТЕКУЩИЙ аккаунт Firebase Auth безвозвратно (Google Play требует
  /// эту возможность для приложений с регистрацией — см. Настройки).
  /// ВАЖНО: вызывающий код должен удалить данные пользователя (Firestore/
  /// Hive) ДО этого вызова, пока `request.auth.uid` ещё валиден для правил
  /// безопасности Firestore — см. DeleteAccount usecase.
  Future<void> deleteAccount();
}
