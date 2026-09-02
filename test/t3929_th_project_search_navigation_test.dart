// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_search_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/elements/th_project_search/th_project_search_match.dart';
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
  late String cavePath;

  THProjectSearchController c() => mpLocator.thProjectSearchController;

  Future<void> setUpProjectAndSearch(WidgetTester tester) async {
    await tester.runAsync(() async {
      tempDir = Directory.systemTemp.createTempSync('mapiah_search_nav_');
      File(p.join(tempDir!.path, 'thconfig')).writeAsStringSync(
        'encoding UTF-8\nsource cave.th\n',
      );
      cavePath = p.join(tempDir!.path, 'cave.th');
      File(cavePath).writeAsStringSync(
        'survey cave\n  point 0 0 station\n# marker line\nendsurvey\n',
      );
      await mpLocator.thProjectController.openProject(
        p.join(tempDir!.path, 'thconfig'),
      );
      c().setScope(THProjectSearchScope.projectFiles);
      c().setQuery('marker');
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

  testWidgets('activating a result opens a tab and records the exact range', (
    WidgetTester tester,
  ) async {
    await setUpProjectAndSearch(tester);

    await tester.pumpWidget(wrap());
    await tester.pump();

    // Expand the file group, then tap the match row.
    await tester.tap(
      find.byKey(
        ValueKey<String>(
          'THProjectSearchResultWidget|Group|${c().results.single.canonicalPath}',
        ),
      ),
    );
    await tester.pump();

    final THProjectSearchMatch match = c().results.single.matches.single;
    await tester.tap(
      find.byKey(
        ValueKey<String>(
          'THProjectSearchResultWidget|Match|${match.canonicalPath}|'
          '${match.range.start}',
        ),
      ),
    );
    await tester.pump();

    expect(
      mpLocator.mpGeneralController.openFileOrder.map(p.normalize),
      contains(p.normalize(cavePath)),
    );
    final THTextEditorController? editor = mpLocator.mpGeneralController
        .getTextEditorControllerIfExists(cavePath);
    expect(editor, isNotNull);
    expect(editor!.pendingSelectionRange, match.range);
  });

  testWidgets('matchIsStillValid detects a match that no longer exists', (
    WidgetTester tester,
  ) async {
    await setUpProjectAndSearch(tester);
    final THProjectSearchMatch match = c().results.single.matches.single;

    await tester.runAsync(() async {
      // Replace the file content so the recorded offset no longer holds
      // "marker".
      mpLocator.thProjectController.registerTextContentChange(
        canonicalPath: cavePath,
        content: 'survey cave\nendsurvey\n',
        expectedProjectEpoch: mpLocator.thProjectController.projectEpoch,
        expectedRootPath: mpLocator.thProjectController.rootConfigPath,
      );
    });

    expect(c().matchIsStillValid(match), isFalse);
  });
}
