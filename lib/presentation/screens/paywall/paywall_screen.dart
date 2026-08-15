import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/generated/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/paywall_provider.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';

/// Экран Paywall (маршрут `AppRoutes.paywall`, Этап 6, см.
/// FLUTTER_ARCHITECTURE_PLAN.md §3). Единственный вход сюда сейчас — кнопка
/// `l10n.magicBallGoToPaywall` на экране Магического Шара (см.
/// `context.push(AppRoutes.paywall)` в magic_ball_screen.dart), поэтому
/// возврат после успешной покупки/восстановления сделан через
/// `context.pop()` с фолбэком на `context.go(AppRoutes.homeMap)`, если
/// экран почему-то оказался корнем навигационного стека — тот же паттерн,
/// что и кнопка "Вернуться" в magic_ball_screen.dart.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String _selectedProductId = kYearlyProductId;

  void _goBackOrHome() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.homeMap);
    }
  }

  Package? _packageFor(Offerings? offerings, String productId) {
    final List<Package>? packages = offerings?.current?.availablePackages;
    if (packages == null) return null;
    for (final Package package in packages) {
      if (package.storeProduct.identifier == productId) return package;
    }
    return null;
  }

  Future<void> _onContinuePressed(PaywallNotifier notifier) async {
    final bool success = await notifier.purchase(_selectedProductId);
    if (success && mounted) {
      _goBackOrHome();
    }
  }

  Future<void> _onRestorePressed(
    PaywallNotifier notifier,
    AppLocalizations l10n,
  ) async {
    final bool success = await notifier.restore();
    if (!mounted) return;
    if (success) {
      _goBackOrHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.paywallRestoreFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final PaywallState state = ref.watch(paywallProvider);
    final PaywallNotifier notifier = ref.read(paywallProvider.notifier);

    // Показываем SnackBar только когда причина ошибки реально изменилась —
    // без этого условия SnackBar лез бы на каждый ребилд экрана (напр. от
    // выбора другого тарифа), пока errorReason не сброшен.
    ref.listen<PaywallState>(paywallProvider, (previous, next) {
      if (next.errorReason == null) return;
      if (next.errorReason == previous?.errorReason) return;
      final String message = switch (next.errorReason!) {
        PaywallErrorReason.purchaseUnavailable => l10n.paywallPurchaseUnavailable,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    });

    final Package? monthlyPackage = _packageFor(state.offerings, kMonthlyProductId);
    final Package? yearlyPackage = _packageFor(state.offerings, kYearlyProductId);
    final Package? lifetimePackage = _packageFor(state.offerings, kLifetimeProductId);

    // Язык интерфейса — для форматирования СТАТИЧНОГО fallback (пунктуация/
    // позиция символа €, Этап 11), НЕ для реальных цен стора (те уже
    // отформатированы самим RevenueCat/стором под локаль и валюту устройства).
    final String localeCode = Localizations.localeOf(context).languageCode;

    // Реальная цена из стора (уже отформатирована под локаль пользователя),
    // либо статичный fallback из ТЗ — см. CurrencyFormatter и задание, пункт F.
    final String monthlyPriceLabel =
        monthlyPackage?.storeProduct.priceString ??
            CurrencyFormatter.formatEur(kMonthlyPriceEur, localeCode: localeCode);
    final String yearlyPriceLabel =
        yearlyPackage?.storeProduct.priceString ??
            CurrencyFormatter.formatEur(kYearlyPriceEur, localeCode: localeCode);
    final String lifetimePriceLabel =
        lifetimePackage?.storeProduct.priceString ??
            CurrencyFormatter.formatEur(kLifetimePriceEur, localeCode: localeCode);

    final num savingsAmount =
        (monthlyPackage != null && yearlyPackage != null)
            ? monthlyPackage.storeProduct.price * 12 -
                yearlyPackage.storeProduct.price
            : kMonthlyPriceEur * 12 - kYearlyPriceEur;
    final String savingsBadge = l10n.paywallYearlySavings(
      CurrencyFormatter.formatEur(savingsAmount, localeCode: localeCode),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            children: [
              Text(
                l10n.paywallTitle,
                style: AppTextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.paywallSubtitle,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _PlanCard(
                      title: l10n.paywallMonthly,
                      priceLabel: monthlyPriceLabel,
                      selected: _selectedProductId == kMonthlyProductId,
                      onTap: () =>
                          setState(() => _selectedProductId = kMonthlyProductId),
                    ),
                    _PlanCard(
                      title: l10n.paywallYearly,
                      priceLabel: yearlyPriceLabel,
                      badge: savingsBadge,
                      selected: _selectedProductId == kYearlyProductId,
                      onTap: () =>
                          setState(() => _selectedProductId = kYearlyProductId),
                    ),
                    _PlanCard(
                      title: l10n.paywallLifetime,
                      priceLabel: lifetimePriceLabel,
                      selected: _selectedProductId == kLifetimeProductId,
                      onTap: () => setState(
                        () => _selectedProductId = kLifetimeProductId,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: Center(
                  child: state.isPurchasing
                      ? const CircularProgressIndicator(color: AppColors.softGold)
                      : NeumorphicButton(
                          label: l10n.paywallContinue,
                          onPressed: () => _onContinuePressed(notifier),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: state.isPurchasing
                    ? null
                    : () => _onRestorePressed(notifier, l10n),
                child: Text(
                  l10n.paywallRestoreButton,
                  style: AppTextStyles.bodySecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка одного тарифа — выбор через tap (radio-style highlight), тот же
/// неоморфный стиль карточки, что и `_BlockCard` в magic_ball_screen.dart.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.priceLabel,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String priceLabel;
  final bool selected;
  final VoidCallback onTap;

  /// Бейдж экономии — только у годового тарифа, см. `paywallYearlySavings`.
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          border: Border.all(
            color: selected ? AppColors.softGold : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.softGold : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium),
                  if (badge != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      badge!,
                      style: AppTextStyles.bodySecondary
                          .copyWith(color: AppColors.emerald),
                    ),
                  ],
                ],
              ),
            ),
            Text(priceLabel, style: AppTextStyles.titleMedium),
          ],
        ),
      ),
    );
  }
}
