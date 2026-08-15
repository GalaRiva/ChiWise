import 'package:chiwise_magic/core/localization/generated/app_localizations.dart';
import 'package:chiwise_magic/presentation/screens/decision_flow/decision_flow_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Cartesian Square decision engine (see decision_flow_provider.dart) —
/// smoke test for the first step only ("doubt" input). Rendered standalone
/// (no go_router ancestor): DecisionFlowScreen only calls `context.go`/`pop`
/// from button callbacks we don't tap here, so a plain MaterialApp is enough.
void main() {
  testWidgets('opens on the doubt-input step', (WidgetTester tester) async {
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
          home: DecisionFlowScreen(),
        ),
      ),
    );
    // Not pumpAndSettle: the doubt-input step keeps a looping "breathing"
    // waveform animation running (see widgets/breathing_waveform.dart), which
    // never settles. A couple of fixed pumps is enough for the first frame.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(l10n.decisionDoubtPrompt), findsOneWidget);
    expect(find.text(l10n.decisionNext), findsOneWidget);
    expect(find.text(l10n.decisionBack), findsNothing); // step 0 has no Back button
  });
}
