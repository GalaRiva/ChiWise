import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../presentation/providers/rating_flow_provider.dart';

/// Обёртка над `in_app_review` и `url_launcher` — экран оценки приложения
/// (Этап 7, см. FLUTTER_ARCHITECTURE_PLAN.md и задание Этапа 7).
///
/// ВАЖНО (тот же паттерн, что и в PurchasesService/SensorsService, см.
/// services/purchases_service.dart, services/sensors_service.dart): в
/// отличие от RevenueCat, `in_app_review` и `url_launcher` НЕ требуют
/// предварительной конфигурации (нет API-ключей и т.п.), поэтому в этой
/// среде разработки они формально могли бы работать. Но платформенные
/// вызовы всё равно могут упасть в рантайме (нет магазина/эмулятора без
/// Play Store, нет установленного почтового клиента и т.д.) — каждый метод
/// сам оборачивает вызов в try/catch и молча деградирует (ничего не
/// показывает, не бросает исключение наружу), а не полагается на
/// вызывающий код.
class ReviewService {
  const ReviewService();

  /// Нативный системный запрос на оценку в сторе (Google Play In-App Review
  /// / App Store SKStoreReviewController). Показывается системой не всегда
  /// (лимиты частоты показов на стороне ОС/стора — вне нашего контроля,
  /// см. `isAvailable()` ниже) — это ОЖИДАЕМОЕ поведение платформы, не баг.
  ///
  /// TODO(in_app_review 2.0.9): сверить точные имена статического
  /// синглтона/методов при первой реальной сборке (нет доступа к
  /// Flutter/Dart SDK и pub.dev в этой песочнице). Наиболее вероятный
  /// актуальный API — `InAppReview.instance.isAvailable()` и
  /// `InAppReview.instance.requestReview()`.
  Future<void> requestNativeReview() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;
      final bool available = await inAppReview.isAvailable();
      if (!available) return;
      await inAppReview.requestReview();
    } catch (_) {
      // Стор недоступен (эмулятор без Google Play, ошибка платформенного
      // канала и т.д.) — молча игнорируем, см. комментарий класса.
    }
  }

  /// Открывает почтовый клиент пользователя (`mailto:`) с темой [subject] и
  /// телом [body], адресат — [kSupportEmail] (см.
  /// presentation/providers/rating_flow_provider.dart — константа лежит там,
  /// а не дублируется здесь, чтобы не разойтись при будущих правках ТЗ).
  ///
  /// TODO(url_launcher 6.3.0): сверить точную сигнатуру `Uri(...)` /
  /// `canLaunchUrl` / `launchUrl` при первой реальной сборке (нет доступа к
  /// Flutter/Dart SDK и pub.dev в этой песочнице). Используется
  /// стандартный для этой версии пакета путь: `Uri(scheme: 'mailto', ...)` +
  /// `canLaunchUrl(uri)` перед `launchUrl(uri)`.
  Future<void> openSupportEmail({
    required String subject,
    required String body,
  }) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: kSupportEmail,
        queryParameters: {'subject': subject, 'body': body},
      );
      final bool canLaunch = await canLaunchUrl(emailUri);
      if (!canLaunch) return;
      await launchUrl(emailUri);
    } catch (_) {
      // Нет установленного почтового клиента / ошибка платформенного канала
      // — молча игнорируем, см. комментарий класса.
    }
  }
}

/// Провайдер сервиса. Конструктор `ReviewService()` ничего не трогает в
/// платформенных SDK (см. комментарий класса), поэтому провайдер не
/// нуждается в try/catch — вся защита находится внутри методов сервиса.
final Provider<ReviewService> reviewServiceProvider =
    Provider<ReviewService>((ref) => const ReviewService());
