import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/link_anonymous_account.dart';
import '../../domain/usecases/auth/sign_in_anonymously.dart';
import '../../domain/usecases/auth/sign_in_with_apple.dart';
import '../../domain/usecases/auth/sign_in_with_google.dart';

/// Состояния сессии авторизации — см. FLUTTER_ARCHITECTURE_PLAN.md, Этап 1.
/// sealed class вместо enum: authenticated-состоянию нужны доп. данные (uid,
/// провайдер), error-состоянию — текст ошибки.
sealed class AuthState {
  const AuthState();
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateAuthenticating extends AuthState {
  const AuthStateAuthenticating();
}

class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated({required this.uid, required this.provider});

  final String uid;
  final AuthProviderType provider;
}

class AuthStateError extends AuthState {
  const AuthStateError(this.message);

  final String message;
}

/// Единственное место, где создаётся конкретная реализация репозитория
/// (firebase_auth + google_sign_in + sign_in_with_apple).
final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firebaseAuth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
  );
});

final Provider<SignInWithGoogle> signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogle>(
  (ref) => SignInWithGoogle(ref.watch(authRepositoryProvider)),
);

final Provider<SignInWithApple> signInWithAppleUseCaseProvider =
    Provider<SignInWithApple>(
  (ref) => SignInWithApple(ref.watch(authRepositoryProvider)),
);

final Provider<SignInAnonymously> signInAnonymouslyUseCaseProvider =
    Provider<SignInAnonymously>(
  (ref) => SignInAnonymously(ref.watch(authRepositoryProvider)),
);

final Provider<LinkAnonymousAccount> linkAnonymousAccountUseCaseProvider =
    Provider<LinkAnonymousAccount>(
  (ref) => LinkAnonymousAccount(ref.watch(authRepositoryProvider)),
);

/// Riverpod-нотифаер сессии авторизации. Presentation-слой (AuthScreen)
/// вызывает методы этого класса, а не usecases/repository напрямую.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // ВАЖНО: конструирование AuthRepositoryImpl обращается к
    // FirebaseAuth.instance, который бросает синхронное исключение, если
    // Firebase.initializeApp() ещё не вызван (см. main.dart — сейчас закомментирован
    // до `flutterfire configure`). Поэтому сам ref.watch() тоже должен быть
    // под try/catch, а не только подписка на поток ниже — иначе весь роутер
    // (который слушает этот провайдер, см. app_router.dart) падает при старте
    // приложения ещё до показа онбординга.
    late final AuthRepository repository;
    try {
      repository = ref.watch(authRepositoryProvider);
    } catch (_) {
      // Firebase ещё не инициализирован (нет lib/config/firebase_options.dart,
      // см. README.md — файл генерируется командой `flutterfire configure`).
      // До этого момента считаем пользователя неавторизованным, чтобы
      // приложение не падало при первом запуске в этой среде разработки.
      return const AuthStateUnauthenticated();
    }

    try {
      final StreamSubscription<String?> subscription =
          repository.authStateChanges().listen((uid) {
        if (uid == null) {
          state = const AuthStateUnauthenticated();
        } else {
          state = AuthStateAuthenticated(
            uid: uid,
            provider:
                repository.currentAuthProvider ?? AuthProviderType.anonymous,
          );
        }
      });
      ref.onDispose(subscription.cancel);
    } catch (_) {
      // См. комментарий выше — тот же сценарий (Firebase не инициализирован).
    }

    return _initialState(repository);
  }

  AuthState _initialState(AuthRepository repository) {
    try {
      final String? uid = repository.currentUserId;
      if (uid == null) return const AuthStateUnauthenticated();
      return AuthStateAuthenticated(
        uid: uid,
        provider: repository.currentAuthProvider ?? AuthProviderType.anonymous,
      );
    } catch (_) {
      return const AuthStateUnauthenticated();
    }
  }

  Future<void> signInAnonymously() =>
      _run(() => ref.read(signInAnonymouslyUseCaseProvider).call());

  Future<void> signInWithGoogle() =>
      _run(() => ref.read(signInWithGoogleUseCaseProvider).call());

  Future<void> signInWithApple() =>
      _run(() => ref.read(signInWithAppleUseCaseProvider).call());

  /// Привязка Google/Apple к текущему анонимному аккаунту без потери данных
  /// (см. AuthRepository.linkAnonymousAccount).
  Future<void> linkAccount(AuthProviderType provider) =>
      _run(() => ref.read(linkAnonymousAccountUseCaseProvider).call(provider));

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthStateUnauthenticated();
  }

  Future<void> _run(Future<String> Function() action) async {
    state = const AuthStateAuthenticating();
    try {
      await action();
      // Основное обновление состояния прилетит через authStateChanges()
      // (см. build()), здесь — подстраховка на случай гонки потоков/платформ,
      // где Stream эмитит значение с задержкой.
      final AuthRepository repository = ref.read(authRepositoryProvider);
      final String? uid = repository.currentUserId;
      if (uid != null) {
        state = AuthStateAuthenticated(
          uid: uid,
          provider:
              repository.currentAuthProvider ?? AuthProviderType.anonymous,
        );
      }
    } catch (e) {
      state = AuthStateError(e.toString());
    }
  }
}

final NotifierProvider<AuthNotifier, AuthState> authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
