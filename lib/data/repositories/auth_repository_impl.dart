import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Реализация [AuthRepository] через firebase_auth + google_sign_in +
/// sign_in_with_apple.
///
/// Account linking: если текущий пользователь Firebase — анонимный
/// (`fb.User.isAnonymous == true`), `linkAnonymousAccount` вызывает
/// `linkWithCredential` вместо signOut+signIn, поэтому uid и все данные,
/// привязанные к нему в Firestore/Hive (черновики решений, прогресс и т.д.,
/// см. следующие этапы), сохраняются — это прямое требование ТЗ.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required fb.FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  AuthProviderType? get currentAuthProvider {
    final fb.User? user = _firebaseAuth.currentUser;
    if (user == null) return null;
    if (user.isAnonymous) return AuthProviderType.anonymous;

    final Iterable<String> providerIds =
        user.providerData.map((info) => info.providerId);
    if (providerIds.contains('google.com')) return AuthProviderType.google;
    if (providerIds.contains('apple.com')) return AuthProviderType.apple;
    return AuthProviderType.anonymous;
  }

  @override
  Stream<String?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<String> signInAnonymously() async {
    final fb.UserCredential credential =
        await _firebaseAuth.signInAnonymously();
    return credential.user!.uid;
  }

  @override
  Future<String> signInWithGoogle() async {
    final fb.OAuthCredential credential = await _googleAuthCredential();
    final fb.UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user!.uid;
  }

  @override
  Future<String> signInWithApple() async {
    final fb.OAuthCredential credential = await _appleAuthCredential();
    final fb.UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    return userCredential.user!.uid;
  }

  @override
  Future<String> linkAnonymousAccount(AuthProviderType provider) async {
    final fb.User? current = _firebaseAuth.currentUser;

    if (current == null || !current.isAnonymous) {
      // Нет активного анонимного пользователя для привязки (edge case —
      // напр. холодный старт без ранее сохранённой анонимной сессии).
      // Ведём себя как обычный вход, чтобы не блокировать пользователя.
      switch (provider) {
        case AuthProviderType.google:
          return signInWithGoogle();
        case AuthProviderType.apple:
          return signInWithApple();
        case AuthProviderType.anonymous:
          return signInAnonymously();
      }
    }

    final fb.OAuthCredential credential = switch (provider) {
      AuthProviderType.google => await _googleAuthCredential(),
      AuthProviderType.apple => await _appleAuthCredential(),
      AuthProviderType.anonymous => throw ArgumentError(
          'Нельзя привязать anonymous-провайдер к анонимному аккаунту.',
        ),
    };

    final fb.UserCredential linked =
        await current.linkWithCredential(credential);
    return linked.user!.uid;
  }

  @override
  Future<void> signOut() async {
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
    await _firebaseAuth.signOut();
  }

  /// google_sign_in ^6.x: `GoogleSignIn().signIn()` -> `GoogleSignInAccount?`,
  /// далее `.authentication` -> accessToken/idToken для Firebase credential.
  Future<fb.OAuthCredential> _googleAuthCredential() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // Пользователь закрыл системный диалог выбора аккаунта.
      throw Exception('Вход через Google отменён пользователем.');
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    return fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  /// sign_in_with_apple: генерируем случайный nonce и передаём его sha256-хэш
  /// в Apple ID запрос, а «сырой» nonce — в Firebase credential. Это защита
  /// от replay-атак, схема описана в официальной документации FlutterFire.
  Future<fb.OAuthCredential> _appleAuthCredential() async {
    final String rawNonce = _generateNonce();
    final String hashedNonce = _sha256ofString(rawNonce);

    final AuthorizationCredentialAppleID appleCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    return fb.OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
  }

  String _generateNonce([int length = 32]) {
    const String charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final Random random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final List<int> bytes = utf8.encode(input);
    final Digest digest = sha256.convert(bytes);
    return digest.toString();
  }
}
