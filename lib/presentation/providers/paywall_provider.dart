import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../data/models/user_model.dart';
import '../../services/analytics_service.dart';
import '../../services/purchases_service.dart';
import 'user_profile_provider.dart';

/// ID тарифов в RevenueCat/сторах — см. FLUTTER_ARCHITECTURE_PLAN.md §3 и
/// задание Этапа 6. Значения зафиксированы ТЗ, менять только синхронно с
/// продуктами в дэшборде RevenueCat/App Store Connect/Google Play Console.
const String kMonthlyProductId = 'sub_monthly_6';
const String kYearlyProductId = 'sub_yearly_24';
const String kLifetimeProductId = 'lifetime_access';

/// Статичные fallback-цены (€) — используются на Paywall (см.
/// paywall_screen.dart), когда реальные офферинги из RevenueCat недоступны.
const num kMonthlyPriceEur = 6;
const num kYearlyPriceEur = 24;
const num kLifetimePriceEur = 57;

/// Единый RevenueCat entitlement (стандартная конвенция RevenueCat),
/// который открывают все три продукта, см. задание Этапа 6.
const String kPremiumEntitlementId = 'premium';

/// Причина последней неудачи в [PaywallNotifier] — экран сам решает, каким
/// локализованным текстом её показать (см. l10n-ключи в paywall_screen.dart).
/// Тот же подход, что и `MagicBallBlockReason` в magic_ball_provider.dart:
/// провайдер не знает про `BuildContext`/`AppLocalizations`, поэтому хранит
/// только причину, а не готовую строку.
enum PaywallErrorReason { purchaseUnavailable }

/// Неизменяемое состояние экрана Paywall.
class PaywallState {
  const PaywallState({
    this.offerings,
    this.isPurchasing = false,
    this.errorReason,
  });

  /// `null` — RevenueCat не сконфигурирован либо офферинги не загрузились.
  /// Это ОЖИДАЕМЫЙ результат в этой среде разработки (см.
  /// services/purchases_service.dart) — экран Paywall в этом случае
  /// показывает статичные цены из ТЗ через CurrencyFormatter.
  final Offerings? offerings;

  /// Идёт покупка/восстановление — экран блокирует кнопку и показывает
  /// индикатор загрузки.
  final bool isPurchasing;

  final PaywallErrorReason? errorReason;

  PaywallState copyWith({
    Offerings? offerings,
    bool? isPurchasing,
    PaywallErrorReason? errorReason,
    bool clearError = false,
  }) {
    return PaywallState(
      offerings: offerings ?? this.offerings,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      errorReason: clearError ? null : (errorReason ?? this.errorReason),
    );
  }
}

/// Riverpod-нотифаер экрана Paywall (Этап 6, см.
/// FLUTTER_ARCHITECTURE_PLAN.md §3). Presentation-слой (PaywallScreen)
/// вызывает только методы этого класса — тот же стиль, что и
/// MagicBallNotifier/AuthNotifier (см. magic_ball_provider.dart,
/// auth_provider.dart).
class PaywallNotifier extends Notifier<PaywallState> {
  @override
  PaywallState build() {
    // Fire-and-forget: build() должен остаться синхронным, результат
    // прилетит через обновление state — тот же паттерн, что и
    // MagicBallNotifier.updateShakeIntensity() -> ask() в magic_ball_provider.dart.
    // ignore: discarded_futures
    _loadOfferings();
    return const PaywallState();
  }

  Future<void> _loadOfferings() async {
    // PurchasesService.getOfferings() сам ловит любые ошибки и возвращает
    // null (RevenueCat не сконфигурирован — ОЖИДАЕМЫЙ случай в этой среде
    // разработки), доп. try/catch тут не нужен, см. класс сервиса.
    final Offerings? offerings =
        await ref.read(purchasesServiceProvider).getOfferings();
    state = state.copyWith(offerings: offerings);
  }

  Package? _findPackage(String productId) {
    final List<Package>? packages =
        state.offerings?.current?.availablePackages;
    if (packages == null) return null;
    for (final Package package in packages) {
      if (package.storeProduct.identifier == productId) return package;
    }
    return null;
  }

  /// Покупка тарифа по `productId` (см. константы `kMonthlyProductId` и т.д.
  /// выше).
  ///  - `true` — покупка прошла, профиль обновлён (см. [_applyCustomerInfo]);
  ///  - `false` без `errorReason` — покупка не удалась или была отменена
  ///    пользователем (см. PurchasesService.purchasePackage — оба случая
  ///    возвращают `null` и намеренно НЕ показывают сообщение об ошибке, см.
  ///    задание Этапа 6, пункт E);
  ///  - `false` с `errorReason == purchaseUnavailable` — офферинги
  ///    недоступны (RevenueCat не сконфигурирован — наш случай в этой среде
  ///    разработки) либо продукт с таким id не найден среди пакетов.
  Future<bool> purchase(String productId) async {
    state = state.copyWith(isPurchasing: true, clearError: true);

    final Package? package = _findPackage(productId);
    if (package == null) {
      state = state.copyWith(
        isPurchasing: false,
        errorReason: PaywallErrorReason.purchaseUnavailable,
      );
      return false;
    }

    final CustomerInfo? customerInfo =
        await ref.read(purchasesServiceProvider).purchasePackage(package);
    state = state.copyWith(isPurchasing: false);

    if (customerInfo == null) return false;
    return _applyCustomerInfo(customerInfo);
  }

  /// Восстановление покупок (стандартное требование App Store, см. кнопку
  /// в paywall_screen.dart). `true` — нашёлся активный `premium`-entitlement
  /// и профиль обновлён; `false` — RevenueCat недоступен либо нет активных
  /// покупок для этого пользователя стора.
  Future<bool> restore() async {
    state = state.copyWith(isPurchasing: true, clearError: true);
    final CustomerInfo? customerInfo =
        await ref.read(purchasesServiceProvider).restorePurchases();
    state = state.copyWith(isPurchasing: false);

    if (customerInfo == null) return false;
    return _applyCustomerInfo(customerInfo);
  }

  /// Разбирает `customerInfo.entitlements.active[kPremiumEntitlementId]` и
  /// сохраняет результат в профиль через
  /// `UserProfileNotifier.updateProfile` (см. задание Этапа 6, пункт E —
  /// новых методов в user_profile_provider.dart не добавляем). Возвращает
  /// `false`, если активного premium-entitlement нет (напр. после
  /// [restore] без реальных покупок у этого пользователя стора).
  ///
  /// `UserModel.copyWith()` умеет явно сбросить `subscriptionExpiresAt` в
  /// `null` через `clearSubscriptionExpiresAt` (sentinel-флаг, добавлен туда
  /// именно под этот случай) — важно для апгрейда с помесячной/годовой
  /// подписки на Lifetime, где `expirationDate` от RevenueCat отсутствует.
  Future<bool> _applyCustomerInfo(CustomerInfo customerInfo) async {
    final EntitlementInfo? entitlement =
        customerInfo.entitlements.active[kPremiumEntitlementId];
    if (entitlement == null) return false;

    final SubscriptionType type =
        _subscriptionTypeFor(entitlement.productIdentifier);
    final DateTime? expiresAt = entitlement.expirationDate == null
        ? null
        : DateTime.tryParse(entitlement.expirationDate!);

    await ref.read(userProfileProvider.notifier).updateProfile(
          (current) => current.copyWith(
            subscriptionType: type,
            subscriptionExpiresAt: expiresAt,
            clearSubscriptionExpiresAt: expiresAt == null,
            revenueCatUserId: customerInfo.originalAppUserId,
          ),
        );

    // ignore: discarded_futures
    ref
        .read(analyticsServiceProvider)
        .logSubscriptionPurchased(entitlement.productIdentifier);

    return true;
  }

  SubscriptionType _subscriptionTypeFor(String productIdentifier) {
    switch (productIdentifier) {
      case kMonthlyProductId:
        return SubscriptionType.monthly;
      case kYearlyProductId:
        return SubscriptionType.yearly;
      case kLifetimeProductId:
        return SubscriptionType.lifetime;
      default:
        // Неизвестный productIdentifier (напр. в дэшборде RevenueCat завели
        // новый SKU, а константу здесь забыли обновить) — консервативно
        // считаем lifetime (без expiresAt), чтобы не заблокировать уже
        // оплаченный пользователем премиум-доступ.
        return SubscriptionType.lifetime;
    }
  }
}

final NotifierProvider<PaywallNotifier, PaywallState> paywallProvider =
    NotifierProvider<PaywallNotifier, PaywallState>(PaywallNotifier.new);
