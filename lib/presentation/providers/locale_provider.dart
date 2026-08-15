import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/shared_prefs_datasource.dart';

/// Поддерживаемые языки интерфейса (см. supportedLocales в app.dart —
/// НЕ трогай этот список отдельно, он уже зафиксирован в app.dart и
/// повторяется здесь только как порядок отображения в SettingsScreen).
const List<String> kSupportedLocaleCodes = ['ru', 'en', 'es', 'fr', 'pt'];

/// Выбранный пользователем язык — `null` означает "как в системе"
/// (MaterialApp.router сам определит locale из устройства среди
/// `supportedLocales`, см. app.dart). Персистентность через
/// SharedPreferences (см. shared_prefs_datasource.dart), тот же паттерн,
/// что и OnboardingSeenNotifier (см. onboarding_provider.dart).
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final String? code = ref.watch(sharedPrefsDatasourceProvider).getLocaleCode();
    return code == null ? null : Locale(code);
  }

  /// `null` — сбросить на язык системы.
  Future<void> setLocale(String? code) async {
    await ref.read(sharedPrefsDatasourceProvider).setLocaleCode(code);
    state = code == null ? null : Locale(code);
  }
}

final NotifierProvider<LocaleNotifier, Locale?> localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
