import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Обёртка над Firebase Analytics — см. FLUTTER_ARCHITECTURE_PLAN.md, Этап 12.
/// ВАЖНО (тот же паттерн, что PurchasesService/ReviewService, см.
/// services/purchases_service.dart, services/review_service.dart): Firebase
/// не сконфигурирован в этой среде разработки — каждый метод сам ловит
/// любую ошибку и молча ничего не делает, вызывающий код не нуждается в
/// собственном try/catch.
class AnalyticsService {
  const AnalyticsService();

  Future<void> logDecisionCompleted({required int decisionsCount}) async {
    try {
      // TODO(firebase_analytics 11.2.1): сверить сигнатуру logEvent — нет
      // доступа к Flutter/Dart SDK и pub.dev в этой песочнице, чтобы
      // скомпилировать и проверить. Ожидается
      // `Future<void> logEvent({required String name, Map<String, Object?>? parameters})`;
      // по правилам вывода типов Dart литерал ниже должен сам привестись к
      // `Map<String, Object?>` из контекста параметра.
      await FirebaseAnalytics.instance.logEvent(
        name: 'decision_completed',
        parameters: {'decisions_count': decisionsCount},
      );
    } catch (_) {}
  }

  Future<void> logAchievementUnlocked(String achievementKey) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'achievement_unlocked',
        parameters: {'achievement_key': achievementKey},
      );
    } catch (_) {}
  }

  Future<void> logMagicBallAsked() async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: 'magic_ball_asked');
    } catch (_) {}
  }

  Future<void> logSubscriptionPurchased(String productId) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'subscription_purchased',
        parameters: {'product_id': productId},
      );
    } catch (_) {}
  }

  Future<void> logRatingSubmitted(int stars) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'rating_submitted',
        parameters: {'stars': stars},
      );
    } catch (_) {}
  }

  Future<void> logMindfulnessLevelUp(String levelKey) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'mindfulness_level_up',
        parameters: {'level': levelKey},
      );
    } catch (_) {}
  }
}

final Provider<AnalyticsService> analyticsServiceProvider =
    Provider<AnalyticsService>((ref) => const AnalyticsService());
