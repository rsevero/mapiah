// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mapiah/src/widgets/th_text_editor_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

import 'th_project_controller_test_aux.dart';
import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator mpLocator = MPLocator();

  Directory? tempDir;
  THTextEditorController? activeController;

  String canonicalPath(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  Widget buildTestApp(THTextEditorController controller) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: THTextEditorWidget(controller: controller)),
    );
  }

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
  });

  tearDown(() {
    activeController?.dispose();
    activeController = null;
    mpLocator.thProjectController.closeProject();
    final Directory? dir = tempDir;

    if ((dir != null) && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    tempDir = null;
  });

  group('THTextEditorController diagnostics', () {
    test('a project parse error on this file appears in diagnostics', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp('missing-file');

      final String thconfigPath = p.join(tempDir!.path, 'thconfig');
      final String thconfigCanonical = canonicalPath(thconfigPath);

      await mpLocator.thProjectController.openProject(thconfigPath);

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      activeController = controller;

      await controller.loadFile(thconfigPath);

      expect(controller.canonicalPath, thconfigCanonical);
      expect(controller.diagnostics, isNotEmpty);
      expect(
        controller.diagnostics.every(
          (error) => error.filePath == thconfigCanonical,
        ),
        isTrue,
      );
      expect(controller.diagnostics.first.lineNumber, 2);
    });

    testWidgets('the gutter shows an error dot for the diagnostic line', (
      WidgetTester tester,
    ) async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp('missing-file');

      final String thconfigPath = p.join(tempDir!.path, 'thconfig');

      // openProject offloads parsing via a Timer-backed Future; run it in
      // the real async zone so it isn't stuck waiting for a fake-clock pump.
      await tester.runAsync(
        () => mpLocator.thProjectController.openProject(thconfigPath),
      );

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      activeController = controller;

      await controller.loadFile(thconfigPath);
      await tester.pumpWidget(buildTestApp(controller));
      await tester.pump();

      expect(find.byType(Tooltip), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    test('diagnostics clear after a successful re-parse fixes the error', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp('missing-file');

      final String thconfigPath = p.join(tempDir!.path, 'thconfig');

      await mpLocator.thProjectController.openProject(thconfigPath);

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      activeController = controller;

      await controller.loadFile(thconfigPath);
      expect(controller.diagnostics, isNotEmpty);

      // The thconfig here is the project root, so reparsing it always falls
      // back to a full reloadProject() that re-reads the file from disk
      // (see shouldFullReloadForReparse). Write the fix to disk first so
      // that reload actually observes it.
      File(thconfigPath).writeAsStringSync('encoding UTF-8\nsource cave.th\n');
      controller.setContent('encoding UTF-8\nsource cave.th\n');
      await Future<void>.delayed(
        const Duration(
          milliseconds:
              mpTextEditorReparseDebounceMilliseconds +
              mpProjectReparseDebounceMilliseconds +
              250,
        ),
      );

      expect(
        mpLocator.thProjectController.projectErrors,
        isEmpty,
        reason: 'removing the "source missing.th" line should fix the error',
      );
    });
  });
}
