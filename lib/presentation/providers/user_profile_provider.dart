import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/decision_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/gamification/record_decision_completed.dart';
import 'auth_provider.dart';

final Provider<RecordDecisionCompleted> recordDecisionCompletedUseCaseProvider =
    Provider<RecordDecisionCompleted>((ref) => const RecordDecisionCompleted());

/// Riverpod-нотифаер профиля пользователя (карта локаций + геймификация,
/// Этап 4). `null` — профиль ещё не загружен/не создан (пользователь не
/// авторизован либо идёт первичная загрузка).
///
/// Presentation-слой (HomeMapScreen и т.д.) вызывает методы этого класса, а
/// не usecases/репозиторий напрямую — тот же стиль, что и AuthNotifier (см.
/// auth_provider.dart).
class UserProfileNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    final AuthState authState = ref.watch(authNotifierProvider);
    if (authState is! AuthStateAuthenticated) return null;

    // ВАЖНО (тот же паттерн, что задокументирован в AuthNotifier.build() и в
    // задании к этому этапу): обращение к репозиторию/датасорсам тут в теории
    // может задеть Firebase (FirestoreUserDatasource), а Firebase может быть
    // ещё не инициализирован (см. main.dart, до `flutterfire configure`).
    // Hive-часть должна работать всегда, но не рискуем — весь блок под
    // try/catch, чтобы падение здесь не роняло роутер/карту локаций.
    try {
      final UserRepository repository = ref.watch(userRepositoryProvider);
      final UserModel? existing = repository.getUser(authState.uid);
      if (existing != null) return existing;

      final DateTime now = DateTime.now();
      final UserModel created = UserModel(
        id: authState.uid,
        authProvider: authState.provider,
        createdAt: now,
        lastActiveAt: now,
      );
      // Сохраняем сразу, чтобы следующий build() (напр. после hot restart)
      // нашёл уже созданный профиль, а не создавал новый каждый раз.
      // ignore: discarded_futures
      repository.saveUser(created);
      return created;
    } catch (_) {
      return null;
    }
  }

  /// Пересчитывает и сохраняет профиль после завершённого решения (кнопка
  /// «Решение принято», см. decision_summary_screen.dart). Edge case:
  /// если профиль ещё не загружен (`state == null`) — ничего не делает.
  Future<void> recordDecisionCompleted(DecisionModel decision) async {
    final UserModel? current = state;
    if (current == null) return;

    final RecordDecisionCompleted usecase =
        ref.read(recordDecisionCompletedUseCaseProvider);
    final UserModel updated = usecase(current, decision);

    try {
      final UserRepository repository = ref.read(userRepositoryProvider);
      await repository.saveUser(updated);
    } catch (_) {
      // См. комментарий в build() — тот же сценарий (Firebase недоступен),
      // Hive-запись внутри репозитория уже произошла до возможной ошибки
      // Firestore-зеркала (см. UserRepositoryImpl), так что состояние ниже
      // всё равно безопасно обновить.
    }

    state = updated;
  }

  /// Обновляет и сохраняет профиль произвольной функцией — используется,
  /// когда изменение не связано с завершением решения (напр. трата энергии
  /// Шара при вопросе, см. presentation/providers/magic_ball_provider.dart,
  /// Этап 5).
  Future<void> updateProfile(UserModel Function(UserModel current) update) async {
    final UserModel? current = state;
    if (current == null) return;
    final UserModel updated = update(current);
    try {
      await ref.read(userRepositoryProvider).saveUser(updated);
    } catch (_) {
      // См. комментарий в build()/recordDecisionCompleted — тот же сценарий.
    }
    state = updated;
  }
}

final NotifierProvider<UserProfileNotifier, UserModel?> userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserModel?>(UserProfileNotifier.new);
