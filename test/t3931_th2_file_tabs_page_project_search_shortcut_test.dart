// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '/tmp';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProviderPlatform();

  final MPLocator mpLocator = MPLocator();

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
    mpLocator.thProjectController.closeProject();
    mpLocator.thProjectTreeUIController.showTree();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpSettingsController.setBool(
      MPSettingID.Main_TelemetryConsent,
      true,
    );
  });

  tearDown(() {
    mpLocator.thProjectTreeUIController.showTree();
    mpLocator.thProjectController.closeProject();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TH2FileTabsPage(
          pickProjectAndRunTherion: (_) async {},
        ),
      ),
    );
    await tester.pump();
  }

  for (final LogicalKeyboardKey modifier in <LogicalKeyboardKey>[
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.metaLeft,
  ]) {
    testWidgets('$modifier+Shift+F opens project search and refocuses on repeat', (
      WidgetTester tester,
    ) async {
      await pumpPage(tester);

      final THProjectTreeUIController ui = mpLocator.thProjectTreeUIController;
      expect(ui.sidebarMode, THProjectSidebarMode.tree);
      final int baseGeneration = ui.projectSearchFocusRequestGeneration;

      Future<void> pressShortcut() async {
        await tester.sendKeyDownEvent(modifier);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyUpEvent(modifier);
        await tester.pump();
      }

      await pressShortcut();
      expect(ui.sidebarMode, THProjectSidebarMode.projectSearch);
      expect(ui.projectSearchFocusRequestGeneration, baseGeneration + 1);

      await pressShortcut();
      expect(ui.sidebarMode, THProjectSidebarMode.projectSearch);
      expect(ui.projectSearchFocusRequestGeneration, baseGeneration + 2);
    });
  }

  testWidgets('a collapsed sidebar is expanded by the shortcut', (
    WidgetTester tester,
  ) async {
    mpLocator.thProjectTreeUIController.setSidebarCollapsed(true);
    await pumpPage(tester);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(mpLocator.thProjectTreeUIController.isSidebarCollapsed, isFalse);
    expect(
      mpLocator.thProjectTreeUIController.sidebarMode,
      THProjectSidebarMode.projectSearch,
    );

    // Drain the sidebar-collapsed persistence debounce timer.
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('plain Ctrl+F does not switch the sidebar to search mode', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(
      mpLocator.thProjectTreeUIController.sidebarMode,
      THProjectSidebarMode.tree,
    );
  });
}
