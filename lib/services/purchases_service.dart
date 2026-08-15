import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Обёртка над `purchases_flutter` (RevenueCat) — монетизация (Этап 6, см.
/// FLUTTER_ARCHITECTURE_PLAN.md §3 и задание Этапа 6).
///
/// ВАЖНО (тот же паттерн, что и в SensorsService/AuthNotifier, см.
/// services/sensors_service.dart и
/// presentation/providers/auth_provider.dart): `Purchases.configure()` в
/// этой среде разработки НИКЕМ не вызывается (нет реального RevenueCat-
/// проекта/API-ключа, см. TODO-блок в main.dart) — любое обращение к
/// `Purchases.*` до `configure()` бросает исключение. Поэтому КАЖДЫЙ
/// публичный метод этого сервиса сам оборачивает вызов в try/catch и
/// возвращает `null`/ничего не делает при любой ошибке — вызывающий код
/// (см. presentation/providers/paywall_provider.dart) может звать эти методы
/// без собственного try/catch; `null` тут ОЖИДАЕМЫЙ и нормальный результат
/// в этой среде разработки, а не баг.
class PurchasesService {
  const PurchasesService();

  /// Инициализация RevenueCat SDK. В этой среде разработки не вызывается из
  /// main.dart (нет реального API-ключа) — метод существует готовым к
  /// использованию на релизе (см. TODO-блок в main.dart).
  Future<void> configure(String apiKey) async {
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
    } catch (_) {
      // Конфигурация не удалась (неверный ключ, платформа не поддерживается
      // и т.д.) — молча деградируем, см. комментарий класса.
    }
  }

  /// Текущие офферинги/пакеты из RevenueCat. `null`, если Purchases не
  /// сконфигурирован (см. комментарий класса — ОЖИДАЕМЫЙ результат в этой
  /// среде разработки), нет сети, либо любая другая ошибка SDK. Экран
  /// Paywall (см. presentation/screens/paywall/paywall_screen.dart) в этом
  /// случае показывает статичные цены из ТЗ.
  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (_) {
      return null;
    }
  }

  /// Покупка пакета. `null` — как при реальной ошибке SDK, так и при
  /// осознанной отмене покупки пользователем
  /// (`PurchasesErrorCode.purchaseCancelledError`) — для вызывающего кода
  /// (paywall_provider.dart) оба случая означают одно и то же: "подписка не
  /// оформлена", отдельного сообщения про отмену пользователю не показываем.
  ///
  /// В purchases_flutter 9+ `Purchases.purchasePackage()` возвращает
  /// `PurchaseResult` (обёртка над `{customerInfo, storeTransaction}`), а не
  /// `CustomerInfo` напрямую, как в более старых версиях SDK — отсюда
  /// `.customerInfo` ниже.
  Future<CustomerInfo?> purchasePackage(Package package) async {
    try {
      final PurchaseResult result =
          await Purchases.purchase(PurchaseParams.package(package));
      return result.customerInfo;
    } on PlatformException catch (e) {
      final PurchasesErrorCode errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // Пользователь сам закрыл системный диалог покупки — осознанная
        // отмена, а не ошибка, см. комментарий метода.
        return null;
      }
      // Любая другая ошибка SDK (сеть, конфигурация, отклонённый платёж и
      // т.д.) — тоже null, см. комментарий класса.
      return null;
    } catch (_) {
      // Purchases не сконфигурирован и т.п. (исключение не от платформенного
      // канала) — см. комментарий класса.
      return null;
    }
  }

  /// Восстановление покупок (стандартное требование App Store — кнопка
  /// "Восстановить покупки" на Paywall, см. paywall_screen.dart). `null` при
  /// любой ошибке (в т.ч. Purchases не сконфигурирован).
  Future<CustomerInfo?> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } catch (_) {
      return null;
    }
  }
}

/// Провайдер сервиса. Конструктор `PurchasesService()` ничего не трогает в
/// RevenueCat (см. комментарий класса), поэтому провайдер не нуждается в
/// try/catch — вся защита находится внутри методов сервиса.
final Provider<PurchasesService> purchasesServiceProvider =
    Provider<PurchasesService>((ref) => const PurchasesService());
