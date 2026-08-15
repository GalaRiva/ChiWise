import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/onboarding_provider.dart';
import '../../presentation/screens/achievements/achievements_screen.dart';
import '../../presentation/screens/auth/auth_screen.dart';
import '../../presentation/screens/decision_detail/decision_detail_screen.dart';
import '../../presentation/screens/decision_flow/decision_flow_screen.dart';
import '../../presentation/screens/decision_summary/decision_summary_screen.dart';
import '../../presentation/screens/home_map/home_map_screen.dart';
import '../../presentation/screens/magic_ball/magic_ball_screen.dart';
import '../../presentation/screens/mindfulness/mindfulness_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/paywall/paywall_screen.dart';
import '../../presentation/screens/rating/rating_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/stats/stats_screen.dart';

/// Пути маршрутов по разделам ТЗ. Каждый экран подключается по мере
/// реализации соответствующего этапа плана разработки (см. FLUTTER_ARCHITECTURE_PLAN.md §5).
abstract class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String homeMap = '/';
  static const String decisionFlow = '/decision-flow';
  static const String decisionSummary = '/decision-summary';

  /// Параметризованный маршрут (см. GoRoute ниже, `state.pathParameters['id']`).
  /// Используй [decisionDetailPath] для построения конкретного URL при
  /// переходе (напр. с карты локаций — Этап 4), а не эту константу напрямую.
  static const String decisionDetail = '/decision-detail/:id';
  static const String magicBall = '/magic-ball';
  static const String achievements = '/achievements';
  static const String profileStats = '/profile-stats';
  static const String settings = '/settings';
  static const String paywall = '/paywall';
  static const String ratingFlow = '/rating-flow';

  /// Экран статистики (Этап 10b) — bubble chart истории решений.
  static const String decisionStats = '/decision-stats';

  /// Строит конкретный URL записи решения из [decisionDetail], напр.
  /// `AppRoutes.decisionDetailPath('abc123')` -> `/decision-detail/abc123`.
  static String decisionDetailPath(String id) => '/decision-detail/$id';
}

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  // Слушаем состояния онбординга и авторизации: при их изменении провайдер
  // пересобирается, GoRouter создаётся заново. app.dart уже подписан на этот
  // провайдер (`ref.watch(appRouterProvider)`) и обновит MaterialApp.router —
  // такой простой пересчёт вместо ChangeNotifier/refreshListenable выбран
  // намеренно для Этапа 1 (redirect ниже сам разруливает актуальный маршрут
  // независимо от того, с какого экрана произошёл пересчёт).
  final bool onboardingSeen = ref.watch(onboardingSeenProvider);
  final AuthState authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    redirect: (context, state) {
      final bool goingToOnboarding =
          state.matchedLocation == AppRoutes.onboarding;
      final bool goingToAuth = state.matchedLocation == AppRoutes.auth;

      // 1. Онбординг не пройден -> всегда онбординг.
      if (!onboardingSeen) {
        return goingToOnboarding ? null : AppRoutes.onboarding;
      }

      // 2. Онбординг пройден, но пользователь не авторизован -> экран входа.
      final bool isAuthenticated = authState is AuthStateAuthenticated;
      if (!isAuthenticated) {
        return goingToAuth ? null : AppRoutes.auth;
      }

      // 3. Онбординг пройден и пользователь авторизован -> карта локаций
      // (не пускаем обратно на onboarding/auth).
      if (goingToOnboarding || goingToAuth) {
        return AppRoutes.homeMap;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.homeMap,
        builder: (context, state) => const HomeMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.decisionFlow,
        builder: (context, state) => const DecisionFlowScreen(),
      ),
      GoRoute(
        path: AppRoutes.decisionSummary,
        builder: (context, state) => const DecisionSummaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.decisionDetail,
        builder: (context, state) => DecisionDetailScreen(
          decisionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.magicBall,
        builder: (context, state) => const MagicBallScreen(),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileStats,
        builder: (context, state) => const MindfulnessScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: AppRoutes.ratingFlow,
        builder: (context, state) => const RatingScreen(),
      ),
      GoRoute(
        path: AppRoutes.decisionStats,
        builder: (context, state) => const StatsScreen(),
      ),
    ],
  );
});
