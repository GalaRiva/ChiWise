import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../models/user_model.dart';

/// Провайдер открытого Hive-бокса `user_profile_cache`. Тот же паттерн, что и
/// `decisionsBoxProvider` (см. hive_decisions_datasource.dart) — `Hive.openBox<Map>(...)`
/// асинхронный, поэтому инстанс создаётся один раз в main.dart (await до
/// runApp) и прокидывается сюда через `ProviderScope(overrides: [...])`.
final Provider<Box<Map>> userProfileBoxProvider = Provider<Box<Map>>((ref) {
  throw UnimplementedError(
    'userProfileBoxProvider должен быть переопределён в main.dart через '
    'ProviderScope(overrides: [userProfileBoxProvider.overrideWithValue(box)])',
  );
});

/// Локальный источник данных для профиля пользователя — Hive-бокс
/// `user_profile_cache`, ключ записи — uid.
///
/// ВАЖНО: намеренно НЕ используем `UserModel.toJson()/fromJson()` — они
/// рассчитаны на `cloud_firestore.Timestamp` (тот же принцип, что и в
/// HiveDecisionsDatasource, см. комментарий там). Здесь даты хранятся как
/// `millisecondsSinceEpoch` (int), enum'ы — через `.name`, `achievements`
/// (Map<String, DateTime>) — тоже через `millisecondsSinceEpoch`. Box
/// типизирован как `Box<Map>` без кастомных Hive-адаптеров.
class HiveUserDatasource {
  const HiveUserDatasource(this._box);

  final Box<Map> _box;

  UserModel? getUser(String uid) {
    final Map? raw = _box.get(uid);
    if (raw == null) return null;
    return _fromMap(raw);
  }

  Future<void> saveUser(UserModel user) {
    return _box.put(user.id, _toMap(user));
  }

  // --- Сериализация ---

  Map<String, dynamic> _toMap(UserModel user) {
    return {
      'id': user.id,
      'authProvider': user.authProvider.name,
      'displayName': user.displayName,
      'email': user.email,
      'languageCode': user.languageCode,
      'createdAt': user.createdAt.millisecondsSinceEpoch,
      'lastActiveAt': user.lastActiveAt.millisecondsSinceEpoch,
      'decisionsCount': user.decisionsCount,
      'currentLocationIndex': user.currentLocationIndex,
      'streakDays': user.streakDays,
      'lastDecisionDate': user.lastDecisionDate?.millisecondsSinceEpoch,
      'magicBallUses': user.magicBallUses,
      'magicBallEnergy': user.magicBallEnergy,
      'subscriptionType': user.subscriptionType.name,
      'subscriptionExpiresAt':
          user.subscriptionExpiresAt?.millisecondsSinceEpoch,
      'revenueCatUserId': user.revenueCatUserId,
      'achievements': user.achievements.map(
        (key, value) => MapEntry(key, value.millisecondsSinceEpoch),
      ),
      'homeDecorUnlocked': user.homeDecorUnlocked,
      'mindfulnessScore': user.mindfulnessScore,
      'mindfulnessLevel': user.mindfulnessLevel.name,
      'ratingPromptsShown': user.ratingPromptsShown,
      'lastDecisionTag': user.lastDecisionTag,
      'sameTagStreak': user.sameTagStreak,
      'magicBallUsedDuringCurrentTagStreak':
          user.magicBallUsedDuringCurrentTagStreak,
      'magicBallUsesToday': user.magicBallUsesToday,
      'magicBallUsesTodayDate':
          user.magicBallUsesTodayDate?.millisecondsSinceEpoch,
    };
  }

  UserModel _fromMap(Map raw) {
    // Тот же приём, что и в HiveDecisionsDatasource._fromMap: Hive при чтении
    // с диска отдаёт `Map` без гарантированной статической типизации ключей,
    // поэтому явно приводим тип через `Map<String, dynamic>.from(...)`.
    final Map<String, dynamic> map = Map<String, dynamic>.from(raw);

    final Map<String, dynamic> rawAchievements =
        map['achievements'] == null
            ? const {}
            : Map<String, dynamic>.from(map['achievements'] as Map);
    final Map<String, DateTime> achievements = rawAchievements.map(
      (key, value) =>
          MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value as int)),
    );

    return UserModel(
      id: map['id'] as String,
      authProvider:
          AuthProviderType.values.byName(map['authProvider'] as String),
      displayName: map['displayName'] as String?,
      email: map['email'] as String?,
      languageCode: map['languageCode'] as String? ?? 'en',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      lastActiveAt:
          DateTime.fromMillisecondsSinceEpoch(map['lastActiveAt'] as int),
      decisionsCount: map['decisionsCount'] as int? ?? 0,
      currentLocationIndex: map['currentLocationIndex'] as int? ?? 0,
      streakDays: map['streakDays'] as int? ?? 0,
      lastDecisionDate: map['lastDecisionDate'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['lastDecisionDate'] as int),
      magicBallUses: map['magicBallUses'] as int? ?? 0,
      magicBallEnergy: map['magicBallEnergy'] as int? ?? 100,
      subscriptionType: SubscriptionType.values.byName(
        map['subscriptionType'] as String? ?? 'none',
      ),
      subscriptionExpiresAt: map['subscriptionExpiresAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['subscriptionExpiresAt'] as int),
      revenueCatUserId: map['revenueCatUserId'] as String?,
      achievements: achievements,
      homeDecorUnlocked:
          List<String>.from(map['homeDecorUnlocked'] as List? ?? const []),
      mindfulnessScore: map['mindfulnessScore'] as int? ?? 0,
      mindfulnessLevel: MindfulnessLevel.values.byName(
        map['mindfulnessLevel'] as String? ?? 'seeker',
      ),
      ratingPromptsShown:
          List<int>.from(map['ratingPromptsShown'] as List? ?? const []),
      lastDecisionTag: map['lastDecisionTag'] as String?,
      sameTagStreak: map['sameTagStreak'] as int? ?? 0,
      magicBallUsedDuringCurrentTagStreak:
          map['magicBallUsedDuringCurrentTagStreak'] as bool? ?? false,
      magicBallUsesToday: map['magicBallUsesToday'] as int? ?? 0,
      magicBallUsesTodayDate: map['magicBallUsesTodayDate'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['magicBallUsesTodayDate'] as int),
    );
  }
}

final Provider<HiveUserDatasource> hiveUserDatasourceProvider =
    Provider<HiveUserDatasource>((ref) {
  final Box<Map> box = ref.watch(userProfileBoxProvider);
  return HiveUserDatasource(box);
});
