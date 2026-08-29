// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpSettingsController.setBool(
      MPSettingID.Main_TelemetryConsent,
      true,
    );
  });

  testWidgets('tabs app bar does not overflow on a one-pixel surface', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1, 1));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MapiahApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('TH2FileTabsPageMoreActionsButton')),
      findsNothing,
    );
  });

  testWidgets('tabs app bar uses an overflow menu on a narrow surface', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MapiahApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('TH2FileTabsPageMoreActionsButton')),
      findsOneWidget,
    );
  });

  testWidgets('empty project tree exposes project actions when wide', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MapiahApp());
    await tester.pump();

    expect(
      find.byKey(const ValueKey('THProjectTreeOpenProjectButton')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('THProjectTreeRunTherionButton')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('file editor app bar uses an overflow menu when narrow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MapiahApp());
    await tester.binding.setSurfaceSize(const Size(380, 600));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey('TH2FileTabsPageMoreActionsButton')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('TH2FileTabsPageMoreActionsButton')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Save as (Shift+Ctrl+S)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
