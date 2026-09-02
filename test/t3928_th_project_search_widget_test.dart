// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_search_controller.dart';
import 'package:mapiah/src/controllers/th_project_tree_ui_controller.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_scope.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/widgets/th_project_search_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  Directory? tempDir;

  THProjectSearchController c() => mpLocator.thProjectSearchController;

  // `THProjectController.openProject` schedules event-loop futures, so project
  // setup and searching must run in real async, outside the widget tester's
  // fake-async zone.
  Future<void> setUpQuery(
    WidgetTester tester,
    String query, {
    THProjectSearchScope scope = THProjectSearchScope.projectFiles,
  }) async {
    await tester.runAsync(() async {
      tempDir = Directory.systemTemp.createTempSync('mapiah_search_widget_');
      File(p.join(tempDir!.path, 'thconfig')).writeAsStringSync(
        'encoding UTF-8\nsource cave.th\n',
      );
      File(
        p.join(tempDir!.path, 'cave.th'),
      ).writeAsStringSync('survey cave\n# TODO marker\nendsurvey\n');
      await mpLocator.thProjectController.openProject(
        p.join(tempDir!.path, 'thconfig'),
      );
      c().setScope(scope);
      c().setQuery(query);
      await c().submitQuery();
    });
  }

  Widget wrap() => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: const Scaffold(
      body: SizedBox(width: 320, child: THProjectSearchWidget()),
    ),
  );

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.thProjectTreeUIController.showTree();
  });

  tearDown(() async {
    c().setQuery('');
    await c().submitQuery();
    mpLocator.thProjectController.closeProject();
    mpLocator.mpGeneralController.reset();
    final Directory? dir = tempDir;
    if ((dir != null) && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    tempDir = null;
  });

  testWidgets('empty query shows its state; back action returns to tree', (
    WidgetTester tester,
  ) async {
    await setUpQuery(tester, '');

    await tester.pumpWidget(wrap());
    await tester.pump();

    expect(
      find.text(AppLocalizationsEn().projectSearchEmptyQuery),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('THProjectSearchWidget|BackButton')),
    );
    await tester.pump();

    expect(
      mpLocator.thProjectTreeUIController.sidebarMode,
      THProjectSidebarMode.tree,
    );
  });

  testWidgets('a query renders a grouped result, a summary and enables Replace All', (
    WidgetTester tester,
  ) async {
    await setUpQuery(tester, 'marker');

    await tester.pumpWidget(wrap());
    await tester.pump();

    expect(
      find.byKey(const ValueKey('THProjectSearchWidget|Summary')),
      findsOneWidget,
    );
    expect(
      find.byKey(
        ValueKey<String>(
          'THProjectSearchResultWidget|Group|'
          '${c().results.single.canonicalPath}',
        ),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(
              const ValueKey('THProjectSearchWidget|ReplaceAllButton'),
            ),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('Replace All is disabled for an empty query', (
    WidgetTester tester,
  ) async {
    await setUpQuery(tester, '');

    await tester.pumpWidget(wrap());
    await tester.pump();

    expect(
      tester
          .widget<FilledButton>(
            find.byKey(
              const ValueKey('THProjectSearchWidget|ReplaceAllButton'),
            ),
          )
          .onPressed,
      isNull,
    );
  });
}
