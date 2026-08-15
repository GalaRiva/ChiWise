import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'config/firebase_options.dart';
import 'data/datasources/local/hive_decisions_datasource.dart';
import 'data/datasources/local/hive_user_datasource.dart';
import 'data/datasources/local/shared_prefs_datasource.dart';
import 'services/crashlytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Глобальный перехват необработанных ошибок Flutter/Dart — отправляет в
  // Crashlytics (Этап 12, см. lib/services/crashlytics_service.dart).
  // Регистрация обработчиков безопасна и БЕЗ сконфигурированного Firebase —
  // сам CrashlyticsService.recordError() ловит ошибку внутри и молча
  // деградирует, если Firebase не инициализирован (см. комментарий класса).
  const CrashlyticsService crashlyticsService = CrashlyticsService();
  FlutterError.onError = (FlutterErrorDetails details) {
    crashlyticsService.recordError(
      details.exception,
      details.stack,
      fatal: true,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    crashlyticsService.recordError(error, stack, fatal: true);
    return true;
  };

  // Firebase (Этап 2+) — конфигурация сгенерирована `flutterfire configure`
  // в lib/config/firebase_options.dart (проект chi-wise-magic-psy).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

  // TODO(релиз): инициализация RevenueCat (Этап 6, см.
  // lib/services/purchases_service.dart и FLUTTER_ARCHITECTURE_PLAN.md §3).
  // Получить API-ключи (отдельные для iOS/Android) в дэшборде RevenueCat,
  // передать через --dart-define или конфиг, и раскомментировать:
  // await PurchasesService().configure(apiKey);
  // Без этого экран Paywall (см.
  // lib/presentation/screens/paywall/paywall_screen.dart) показывает только
  // статичные цены из ТЗ — офферинги из RevenueCat не подгружаются,
  // PurchasesService.getOfferings() возвращает null (см. PaywallNotifier в
  // lib/presentation/providers/paywall_provider.dart — это ожидаемое
  // поведение в этой среде разработки, а не баг).

  await Hive.initFlutter();
  // Hive-бокс черновиков/решений (Этап 2, см.
  // data/datasources/local/hive_decisions_datasource.dart). Типизирован как
  // Box<Map> и хранит только «нативные» для Hive типы (String, int, bool,
  // Map, null) — кастомные Hive-адаптеры (TypeAdapter/generated .g.dart) не
  // нужны, сериализация DecisionModel <-> Map написана вручную в датасорсе.
  final Box<Map> decisionsBox = await Hive.openBox<Map>('decisions_cache');

  // Hive-бокс профиля пользователя (Этап 4, см.
  // data/datasources/local/hive_user_datasource.dart). Тот же принцип, что и
  // decisionsBox выше — Box<Map>, ручная сериализация, без кастомных
  // Hive-адаптеров.
  final Box<Map> userProfileBox = await Hive.openBox<Map>('user_profile_cache');

  // SharedPreferences читается синхронно во всём приложении (флаг онбординга
  // и т.д., см. shared_prefs_datasource.dart), поэтому инициализируем один
  // раз здесь и прокидываем готовый инстанс через ProviderScope.overrides.
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        decisionsBoxProvider.overrideWithValue(decisionsBox),
        userProfileBoxProvider.overrideWithValue(userProfileBox),
      ],
      child: const ChiWiseMagicApp(),
    ),
  );
}
