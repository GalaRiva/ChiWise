import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/shared_prefs_datasource.dart';

/// Состояние «онбординг пройден» (4 свайп-экрана, см. Этап 1).
/// Читается синхронно при старте — SharedPreferences уже инициализированы
/// до runApp (см. main.dart) — и обновляется при завершении/пропуске
/// онбординга (OnboardingScreen). Используется в redirect-логике go_router
/// (см. core/router/app_router.dart).
class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.watch(sharedPrefsDatasourceProvider).getOnboardingSeen();
  }

  Future<void> markSeen() async {
    await ref.read(sharedPrefsDatasourceProvider).setOnboardingSeen(true);
    state = true;
  }
}

final NotifierProvider<OnboardingSeenNotifier, bool> onboardingSeenProvider =
    NotifierProvider<OnboardingSeenNotifier, bool>(OnboardingSeenNotifier.new);
