// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:material_ui/material_ui.dart';
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
    mpLocator.thProjectController.closeProject();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpSettingsController.setBool(
      MPSettingID.Main_TelemetryConsent,
      true,
    );
  });

  tearDown(() {
    mpLocator.thProjectController.closeProject();
  });

  group('Tabs page Run Therion actions (wide layout)', () {
    testWidgets(
      'Run Therion button is disabled with no project loaded and enabled '
      'once one is',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 700));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(const MapiahApp());
        await tester.pump();

        final Finder runButtonFinder = find.byKey(
          const ValueKey('TH2FileTabsPageRunTherionButton'),
        );

        expect(runButtonFinder, findsOneWidget);
        expect(tester.widget<IconButton>(runButtonFinder).onPressed, isNull);

        mpLocator.thProjectController.rootConfigPath = '/tmp/some/thconfig';
        await tester.pump();

        expect(
          tester.widget<IconButton>(runButtonFinder).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets(
      'project tree exposes the Open project and run Therion action',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 700));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(const MapiahApp());
        await tester.pump();

        final Finder openAndRunButtonFinder = find.byKey(
          const ValueKey('THProjectTreeRunTherionButton'),
        );

        expect(openAndRunButtonFinder, findsOneWidget);
        expect(
          tester.widget<OutlinedButton>(openAndRunButtonFinder).onPressed,
          isNotNull,
        );
      },
    );
  });

  group('Tabs page Run Therion actions (compact overflow menu)', () {
    testWidgets(
      'the overflow menu Run Therion entry is disabled with no project and '
      'enabled once one is loaded',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 600));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(const MapiahApp());
        await tester.pump();

        expect(
          find.byKey(const ValueKey('TH2FileTabsPageMoreActionsButton')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('TH2FileTabsPageMoreActionsButton')),
        );
        await tester.pumpAndSettle();

        final Finder runTherionItemFinder = find.ancestor(
          of: find.text('Run Therion (T)'),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is PopupMenuItem,
          ),
        );

        expect(runTherionItemFinder, findsOneWidget);
        expect(
          (tester.widget(runTherionItemFinder) as PopupMenuItem).enabled,
          isFalse,
        );

        // Close the menu before re-pumping the project state, matching the
        // page's usual interaction flow.
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        mpLocator.thProjectController.rootConfigPath = '/tmp/some/thconfig';
        await tester.pump();

        await tester.tap(
          find.byKey(const ValueKey('TH2FileTabsPageMoreActionsButton')),
        );
        await tester.pumpAndSettle();

        final Finder runTherionItemFinderAfter = find.ancestor(
          of: find.text('Run Therion (T)'),
          matching: find.byWidgetPredicate(
            (Widget widget) => widget is PopupMenuItem,
          ),
        );

        expect(
          (tester.widget(runTherionItemFinderAfter) as PopupMenuItem)
              .enabled,
          isTrue,
        );
      },
    );
  });
}
