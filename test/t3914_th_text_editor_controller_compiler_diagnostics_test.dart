// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
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

  group('THTextEditorController compiler diagnostics', () {
    test(
      'a THProjectController.compilerErrors entry for this file appears in '
      'diagnostics',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'single-config',
        );

        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String thconfigCanonical = canonicalPath(thconfigPath);

        await mpLocator.thProjectController.openProject(thconfigPath);

        expect(
          mpLocator.thProjectController.projectErrors,
          isEmpty,
          reason: 'single-config is a clean fixture with no parse errors',
        );

        mpLocator.thProjectController.applyTherionRunDiagnostics(
          <THProjectParseError>[
            THProjectParseError(
              message: 'compiler-reported error',
              severity: THProjectParseErrorSeverity.error,
              filePath: thconfigCanonical,
              lineNumber: 2,
            ),
          ],
        );

        final THTextEditorController controller = THTextEditorController(
          projectController: mpLocator.thProjectController,
        );

        activeController = controller;

        await controller.loadFile(thconfigPath);

        expect(controller.canonicalPath, thconfigCanonical);
        expect(controller.diagnostics, hasLength(1));
        expect(
          controller.diagnostics.single.message,
          'compiler-reported error',
        );
        expect(controller.diagnostics.single.lineNumber, 2);
      },
    );

    testWidgets(
      'a compiler diagnostic renders via the existing diagnostic marker '
      'widget path',
      (WidgetTester tester) async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'single-config',
        );

        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String thconfigCanonical = canonicalPath(thconfigPath);

        await tester.runAsync(
          () => mpLocator.thProjectController.openProject(thconfigPath),
        );

        mpLocator.thProjectController.applyTherionRunDiagnostics(
          <THProjectParseError>[
            THProjectParseError(
              message: 'compiler-reported error',
              severity: THProjectParseErrorSeverity.error,
              filePath: thconfigCanonical,
              lineNumber: 1,
            ),
          ],
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
      },
    );

    test(
      'a compiler diagnostic on a different file does not appear here',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'single-config',
        );

        final String thconfigPath = p.join(tempDir!.path, 'thconfig');

        await mpLocator.thProjectController.openProject(thconfigPath);

        mpLocator.thProjectController.applyTherionRunDiagnostics(
          const <THProjectParseError>[
            THProjectParseError(
              message: 'error in a different file',
              severity: THProjectParseErrorSeverity.error,
              filePath: '/tmp/some/other/cave.th',
              lineNumber: 1,
            ),
          ],
        );

        final THTextEditorController controller = THTextEditorController(
          projectController: mpLocator.thProjectController,
        );

        activeController = controller;

        await controller.loadFile(thconfigPath);

        expect(controller.diagnostics, isEmpty);
      },
    );
  });
}
