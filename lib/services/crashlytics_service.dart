import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Обёртка над Firebase Crashlytics — тот же защитный паттерн, что и
/// AnalyticsService (см. выше). Используется в main.dart для глобального
/// перехвата необработанных ошибок (см. Задачу 3).
class CrashlyticsService {
  const CrashlyticsService();

  /// Отправляет ошибку в Crashlytics. [fatal] — считать ли краш фатальным
  /// (напр. необработанное исключение уровня приложения) в терминах
  /// Crashlytics-дэшборда.
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: fatal,
      );
    } catch (_) {
      // Firebase не сконфигурирован в этой среде разработки (см. комментарий
      // класса) — молча игнорируем, чтобы обработчик ошибок сам не стал
      // источником нового краша.
    }
  }
}

final Provider<CrashlyticsService> crashlyticsServiceProvider =
    Provider<CrashlyticsService>((ref) => const CrashlyticsService());
