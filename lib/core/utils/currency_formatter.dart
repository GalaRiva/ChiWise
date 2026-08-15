import 'package:intl/intl.dart';

/// Форматирование СТАТИЧНОГО fallback-текста цены в евро (экран Paywall,
/// Этап 6, см. FLUTTER_ARCHITECTURE_PLAN.md §3) — используется, когда
/// реальных цен из стора/RevenueCat нет (offerings недоступны, см.
/// presentation/providers/paywall_provider.dart).
///
/// ВАЖНО: НЕ использовать для реальных `StoreProduct.priceString` из
/// RevenueCat — они уже отформатированы самим стором под локаль и валюту
/// пользователя (см. `Package.storeProduct.priceString` в paywall_screen.dart).
/// Эта утилита — только для наших собственных чисел из ТЗ (6/24/57), сама
/// сумма всегда в евро (регион не меняет валюту, только пунктуацию/позицию
/// символа — см. [localeCode]).
class CurrencyFormatter {
  CurrencyFormatter._();

  /// `6` -> `€6`, `24` -> `€24`, `6.5` -> `€6.50` (для `localeCode: 'en'`).
  /// Целые суммы — без десятичных знаков, дробные — ровно 2 знака после
  /// запятой. [localeCode] — язык интерфейса пользователя (см.
  /// `Localizations.localeOf(context).languageCode`, Этап 11 — "форматирование
  /// валюты Paywall по региону"): меняет пунктуацию (`,` vs `.` как
  /// десятичный разделитель) и позицию символа `€` относительно числа, напр.
  /// `fr`/`ru` печатают символ после числа с неразрывным пробелом
  /// (`6,00 €`), `en`/`es`/`pt` — перед числом (`€6.00`/`€6,00`). Используем
  /// `intl.NumberFormat.currency` вместо ручной строки, чтобы не
  /// реализовывать эти региональные правила самостоятельно.
  static String formatEur(num amount, {String localeCode = 'en'}) {
    final bool isWhole = amount == amount.roundToDouble();
    final NumberFormat format = NumberFormat.currency(
      locale: localeCode,
      symbol: '€',
      decimalDigits: isWhole ? 0 : 2,
    );
    return format.format(amount);
  }
}
