import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Провайдер конкретного инстанса [SharedPreferences]. `SharedPreferences.getInstance()`
/// асинхронный, а флаг онбординга нужен синхронно (напр. для redirect-логики
/// go_router при первом кадре) — поэтому инстанс создаётся один раз в main.dart
/// (await до runApp) и прокидывается сюда через `ProviderScope(overrides: [...])`.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider должен быть переопределён в main.dart через '
    'ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)])',
  );
});

/// Локальный источник данных на SharedPreferences: пользовательские флаги/
/// настройки, которые не относятся к самим решениям (те — Hive, Этап 2) и не
/// синхронизируются с Firestore. См. FLUTTER_ARCHITECTURE_PLAN.md §1.
class SharedPrefsDatasource {
  const SharedPrefsDatasource(this._prefs);

  final SharedPreferences _prefs;

  static const String _onboardingSeenKey = 'onboarding_seen';

  /// Пройден ли онбординг (4 свайп-экрана). По умолчанию — false (не показан).
  bool getOnboardingSeen() => _prefs.getBool(_onboardingSeenKey) ?? false;

  Future<void> setOnboardingSeen(bool value) =>
      _prefs.setBool(_onboardingSeenKey, value);

  static const String _localeCodeKey = 'locale_code';

  /// Явно выбранный пользователем язык интерфейса (см. SettingsScreen,
  /// Этап 11) — код языка ('ru'/'en'/'es'/'fr'/'pt') либо `null`, если
  /// пользователь ничего не выбирал (используется язык устройства).
  String? getLocaleCode() => _prefs.getString(_localeCodeKey);

  Future<void> setLocaleCode(String? code) {
    if (code == null) return _prefs.remove(_localeCodeKey);
    return _prefs.setString(_localeCodeKey, code);
  }
}

final Provider<SharedPrefsDatasource> sharedPrefsDatasourceProvider =
    Provider<SharedPrefsDatasource>((ref) {
  final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsDatasource(prefs);
});
