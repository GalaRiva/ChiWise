import 'package:cloud_firestore/cloud_firestore.dart';

/// Способ входа. `anonymous` — Firebase Anonymous Auth ("Продолжить без регистрации").
enum AuthProviderType { anonymous, google, apple }

/// Тип активной подписки/покупки. `none` — бесплатный пользователь.
enum SubscriptionType { none, monthly, yearly, lifetime }

/// Уровень «Шкалы осознанности», см. FLUTTER_ARCHITECTURE_PLAN.md §4.
enum MindfulnessLevel {
  seeker,
  observer,
  rationalist,
  balanceMaster,
  guardianOfClarity,
}

/// Документ `users/{uid}` в Firestore.
/// См. FLUTTER_ARCHITECTURE_PLAN.md §2.1 — источник истины по полям.
class UserModel {
  const UserModel({
    required this.id,
    required this.authProvider,
    this.displayName,
    this.email,
    this.languageCode = 'en',
    required this.createdAt,
    required this.lastActiveAt,
    this.decisionsCount = 0,
    this.currentLocationIndex = 0,
    this.streakDays = 0,
    this.lastDecisionDate,
    this.magicBallUses = 0,
    this.magicBallEnergy = 100,
    this.subscriptionType = SubscriptionType.none,
    this.subscriptionExpiresAt,
    this.revenueCatUserId,
    this.achievements = const {},
    this.homeDecorUnlocked = const [],
    this.mindfulnessScore = 0,
    this.mindfulnessLevel = MindfulnessLevel.seeker,
    this.ratingPromptsShown = const [],
    this.lastDecisionTag,
    this.sameTagStreak = 0,
    this.magicBallUsedDuringCurrentTagStreak = false,
    this.magicBallUsesToday = 0,
    this.magicBallUsesTodayDate,
  });

  final String id;
  final AuthProviderType authProvider;
  final String? displayName;
  final String? email;
  final String languageCode;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  /// Суммарное число завершённых (status == completed) решений — двигает геймификацию.
  final int decisionsCount;
  final int currentLocationIndex;
  final int streakDays;
  final DateTime? lastDecisionDate;

  final int magicBallUses;
  final int magicBallEnergy;

  final SubscriptionType subscriptionType;
  final DateTime? subscriptionExpiresAt;
  final String? revenueCatUserId;

  /// Ключ ачивки → дата получения (включая секретные, см. AchievementModel).
  final Map<String, DateTime> achievements;
  final List<String> homeDecorUnlocked;

  final int mindfulnessScore;
  final MindfulnessLevel mindfulnessLevel;

  /// Какие вехи rating flow уже показаны, напр. [3, 10].
  final List<int> ratingPromptsShown;

  /// Тег последнего ЗАВЕРШЁННОГО решения — для расчёта серии одинаковых
  /// категорий (ачивки «Парад планет»/«Идеальное выравнивание»). См.
  /// domain/services/achievement_evaluator.dart.
  final String? lastDecisionTag;

  /// Сколько завершённых решений подряд имеют одинаковый (непустой) тег.
  final int sameTagStreak;

  /// Обращались ли к Магическому Шару хотя бы раз с начала текущей серии
  /// [sameTagStreak] — для секретной ачивки «Идеальное выравнивание».
  final bool magicBallUsedDuringCurrentTagStreak;

  /// Сколько раз спрашивали Магический Шар СЕГОДНЯ (календарный день) — для
  /// ачивки «Испытатель судьбы».
  final int magicBallUsesToday;

  /// Дата (день), к которому относится [magicBallUsesToday].
  final DateTime? magicBallUsesTodayDate;

  /// Есть ли премиум-доступ (любой тариф, включая lifetime — expiresAt == null).
  bool get isSubscribed => subscriptionType != SubscriptionType.none;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      authProvider:
          AuthProviderType.values.byName(json['authProvider'] as String),
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      languageCode: json['languageCode'] as String? ?? 'en',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastActiveAt: (json['lastActiveAt'] as Timestamp).toDate(),
      decisionsCount: json['decisionsCount'] as int? ?? 0,
      currentLocationIndex: json['currentLocationIndex'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      lastDecisionDate: (json['lastDecisionDate'] as Timestamp?)?.toDate(),
      magicBallUses: json['magicBallUses'] as int? ?? 0,
      magicBallEnergy: json['magicBallEnergy'] as int? ?? 100,
      subscriptionType: SubscriptionType.values.byName(
        json['subscriptionType'] as String? ?? 'none',
      ),
      subscriptionExpiresAt:
          (json['subscriptionExpiresAt'] as Timestamp?)?.toDate(),
      revenueCatUserId: json['revenueCatUserId'] as String?,
      achievements:
          (json['achievements'] as Map<String, dynamic>? ?? const {}).map(
        (key, value) => MapEntry(key, (value as Timestamp).toDate()),
      ),
      homeDecorUnlocked:
          List<String>.from(json['homeDecorUnlocked'] as List? ?? const []),
      mindfulnessScore: json['mindfulnessScore'] as int? ?? 0,
      mindfulnessLevel: MindfulnessLevel.values.byName(
        json['mindfulnessLevel'] as String? ?? 'seeker',
      ),
      ratingPromptsShown:
          List<int>.from(json['ratingPromptsShown'] as List? ?? const []),
      lastDecisionTag: json['lastDecisionTag'] as String?,
      sameTagStreak: json['sameTagStreak'] as int? ?? 0,
      magicBallUsedDuringCurrentTagStreak:
          json['magicBallUsedDuringCurrentTagStreak'] as bool? ?? false,
      magicBallUsesToday: json['magicBallUsesToday'] as int? ?? 0,
      magicBallUsesTodayDate:
          (json['magicBallUsesTodayDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authProvider': authProvider.name,
      'displayName': displayName,
      'email': email,
      'languageCode': languageCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'decisionsCount': decisionsCount,
      'currentLocationIndex': currentLocationIndex,
      'streakDays': streakDays,
      'lastDecisionDate':
          lastDecisionDate == null ? null : Timestamp.fromDate(lastDecisionDate!),
      'magicBallUses': magicBallUses,
      'magicBallEnergy': magicBallEnergy,
      'subscriptionType': subscriptionType.name,
      'subscriptionExpiresAt': subscriptionExpiresAt == null
          ? null
          : Timestamp.fromDate(subscriptionExpiresAt!),
      'revenueCatUserId': revenueCatUserId,
      'achievements': achievements
          .map((key, value) => MapEntry(key, Timestamp.fromDate(value))),
      'homeDecorUnlocked': homeDecorUnlocked,
      'mindfulnessScore': mindfulnessScore,
      'mindfulnessLevel': mindfulnessLevel.name,
      'ratingPromptsShown': ratingPromptsShown,
      'lastDecisionTag': lastDecisionTag,
      'sameTagStreak': sameTagStreak,
      'magicBallUsedDuringCurrentTagStreak':
          magicBallUsedDuringCurrentTagStreak,
      'magicBallUsesToday': magicBallUsesToday,
      'magicBallUsesTodayDate': magicBallUsesTodayDate == null
          ? null
          : Timestamp.fromDate(magicBallUsesTodayDate!),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? languageCode,
    DateTime? lastActiveAt,
    int? decisionsCount,
    int? currentLocationIndex,
    int? streakDays,
    DateTime? lastDecisionDate,
    int? magicBallUses,
    int? magicBallEnergy,
    SubscriptionType? subscriptionType,
    DateTime? subscriptionExpiresAt,
    // Обычный `?? this.x` не даёт явно сбросить поле в null (напр. при
    // покупке lifetime — там нет даты истечения, а раньше могла быть
    // активная monthly/yearly подписка с датой). Тот же sentinel-паттерн,
    // что уже используется в MagicBallState/DecisionFlowState.copyWith —
    // см. presentation/providers/magic_ball_provider.dart.
    bool clearSubscriptionExpiresAt = false,
    String? revenueCatUserId,
    Map<String, DateTime>? achievements,
    List<String>? homeDecorUnlocked,
    int? mindfulnessScore,
    MindfulnessLevel? mindfulnessLevel,
    List<int>? ratingPromptsShown,
    String? lastDecisionTag,
    int? sameTagStreak,
    bool? magicBallUsedDuringCurrentTagStreak,
    int? magicBallUsesToday,
    DateTime? magicBallUsesTodayDate,
  }) {
    return UserModel(
      id: id,
      authProvider: authProvider,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      languageCode: languageCode ?? this.languageCode,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      decisionsCount: decisionsCount ?? this.decisionsCount,
      currentLocationIndex: currentLocationIndex ?? this.currentLocationIndex,
      streakDays: streakDays ?? this.streakDays,
      lastDecisionDate: lastDecisionDate ?? this.lastDecisionDate,
      magicBallUses: magicBallUses ?? this.magicBallUses,
      magicBallEnergy: magicBallEnergy ?? this.magicBallEnergy,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionExpiresAt: clearSubscriptionExpiresAt
          ? null
          : (subscriptionExpiresAt ?? this.subscriptionExpiresAt),
      revenueCatUserId: revenueCatUserId ?? this.revenueCatUserId,
      achievements: achievements ?? this.achievements,
      homeDecorUnlocked: homeDecorUnlocked ?? this.homeDecorUnlocked,
      mindfulnessScore: mindfulnessScore ?? this.mindfulnessScore,
      mindfulnessLevel: mindfulnessLevel ?? this.mindfulnessLevel,
      ratingPromptsShown: ratingPromptsShown ?? this.ratingPromptsShown,
      lastDecisionTag: lastDecisionTag ?? this.lastDecisionTag,
      sameTagStreak: sameTagStreak ?? this.sameTagStreak,
      magicBallUsedDuringCurrentTagStreak:
          magicBallUsedDuringCurrentTagStreak ??
              this.magicBallUsedDuringCurrentTagStreak,
      magicBallUsesToday: magicBallUsesToday ?? this.magicBallUsesToday,
      magicBallUsesTodayDate:
          magicBallUsesTodayDate ?? this.magicBallUsesTodayDate,
    );
  }
}
