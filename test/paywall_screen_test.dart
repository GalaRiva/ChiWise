import 'package:chiwise_magic/core/localization/generated/app_localizations.dart';
import 'package:chiwise_magic/presentation/screens/paywall/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// PaywallNotifier.build() fires PurchasesService.getOfferings(), which has
/// no platform channel wired up in `flutter test` and is expected to
/// silently degrade to `null` (see services/purchases_service.dart) — the
/// screen should then fall back to the static ТЗ prices, not crash.
void main() {
  testWidgets('renders the three static plans when RevenueCat is unavailable', (
    WidgetTester tester,
  ) async {
    final AppLocalizations l10n =
        await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: PaywallScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.paywallTitle), findsOneWidget);
    expect(find.text(l10n.paywallMonthly), findsOneWidget);
    expect(find.text(l10n.paywallYearly), findsOneWidget);
    expect(find.text(l10n.paywallLifetime), findsOneWidget);
    expect(find.text(l10n.paywallContinue), findsOneWidget);
  });
}
