import 'dart:io';

import 'package:chiwise_magic/app.dart';
import 'package:chiwise_magic/core/localization/generated/app_localizations.dart';
import 'package:chiwise_magic/data/datasources/local/hive_decisions_datasource.dart';
import 'package:chiwise_magic/data/datasources/local/hive_user_datasource.dart';
import 'package:chiwise_magic/data/datasources/local/shared_prefs_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smoke test for the app's cold-start path: fresh install, onboarding not
/// seen yet, no user signed in. This exercises the same provider overrides
/// as `main.dart` (see lib/main.dart) so the go_router redirect logic in
/// core/router/app_router.dart runs for real, not against a stub.
void main() {
  late Directory tempDir;
  late Box<Map> decisionsBox;
  late Box<Map> userProfileBox;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('chiwise_test_hive_');
    Hive.init(tempDir.path);
    decisionsBox = await Hive.openBox<Map>('decisions_cache');
    userProfileBox = await Hive.openBox<Map>('user_profile_cache');
  });

  tearDownAll(() async {
    await decisionsBox.close();
    await userProfileBox.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('fresh launch redirects to onboarding without crashing', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final AppLocalizations l10n =
        await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          decisionsBoxProvider.overrideWithValue(decisionsBox),
          userProfileBoxProvider.overrideWithValue(userProfileBox),
        ],
        child: const ChiWiseMagicApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.onboardingTitle1), findsOneWidget);
  });
}
