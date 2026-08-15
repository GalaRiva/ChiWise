import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/localization/generated/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/locale_provider.dart';

/// Корневой виджет Chi Wise Magic.
class ChiWiseMagicApp extends ConsumerWidget {
  const ChiWiseMagicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Chi Wise Magic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      // Дизайн ТЗ рассчитан на тёмный фон (Deep Blue) — светлая тема не используется.
      themeMode: ThemeMode.dark,
      routerConfig: router,
      locale: ref.watch(localeProvider),
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('pt'),
      ],
      localizationsDelegates: const [
        // AppLocalizations генерируется командой `flutter gen-l10n` из
        // lib/core/localization/l10n/*.arb (см. l10n.yaml) в
        // lib/core/localization/generated/app_localizations.dart. В этой
        // рабочей среде без Flutter SDK файл не сгенерирован — выполните
        // `flutter gen-l10n` перед первой сборкой (см. README.md).
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
