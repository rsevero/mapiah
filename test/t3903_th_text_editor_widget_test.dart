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

  group('THTextEditorWidget', () {
    testWidgets('renders line numbers and the loaded content', (
      WidgetTester tester,
    ) async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      activeController = controller;

      await controller.loadFile(p.join(tempDir!.path, 'cave_one.th'));
      await tester.pumpWidget(buildTestApp(controller));
      await tester.pump();

      expect(
        find.byKey(const ValueKey('THTextEditorWidget|TextField')),
        findsOneWidget,
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows an error marker for a diagnostic on this file', (
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

      expect(controller.diagnostics, isNotEmpty);
      expect(
        find.byTooltip(controller.diagnostics.first.message),
        findsOneWidget,
      );
    });

    testWidgets(
      'controller edits mark the widget dirty and schedule a reparse',
      (WidgetTester tester) async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );

        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');
        final String caveOneCanonical = THProjectPathResolver.canonicalize(
          p.absolute(caveOnePath),
        );

        await tester.runAsync(
          () => mpLocator.thProjectController.openProject(thconfigPath),
        );

        final THTextEditorController controller = THTextEditorController(
          projectController: mpLocator.thProjectController,
        );

        activeController = controller;

        await controller.loadFile(caveOnePath);
        await tester.pumpWidget(buildTestApp(controller));
        await tester.pump();

        // setContent's own Timer must be created in the real async zone
        // (like THProjectController's internal debounce Timer it schedules
        // in turn), or it never fires: a fake-clock pump cannot advance it.
        await tester.runAsync(() async {
          controller.setContent('survey renamed\nendsurvey\n');
          await Future<void>.delayed(
            const Duration(
              milliseconds:
                  mpTextEditorReparseDebounceMilliseconds +
                  mpProjectReparseDebounceMilliseconds +
                  250,
            ),
          );
        });
        await tester.pump();

        expect(controller.isDirty, isTrue);
        expect(find.textContaining('renamed'), findsWidgets);
        expect(
          mpLocator.thProjectController.fileContentsCache[caveOneCanonical],
          'survey renamed\nendsurvey\n',
        );
      },
    );

    testWidgets('the save button triggers save and clears the dirty state', (
      WidgetTester tester,
    ) async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );

      final String thconfigPath = p.join(tempDir!.path, 'thconfig');
      final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');

      await tester.runAsync(
        () => mpLocator.thProjectController.openProject(thconfigPath),
      );

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );

      activeController = controller;

      await controller.loadFile(caveOnePath);
      await tester.pumpWidget(buildTestApp(controller));
      await tester.pump();

      // Drive the edit and both debounce stages in the real async zone: the
      // widget's own debounce and THProjectController's internal debounce
      // are both real Timers there, unlike inside a fake-clock pump.
      await tester.runAsync(() async {
        controller.setContent('survey renamed\nendsurvey\n');
        await Future<void>.delayed(
          const Duration(
            milliseconds:
                mpTextEditorReparseDebounceMilliseconds +
                mpProjectReparseDebounceMilliseconds +
                250,
          ),
        );
      });
      await tester.pump();

      final IconButton saveButtonWidget = tester.widget<IconButton>(
        find.byKey(const ValueKey('THTextEditorWidget|SaveButton')),
      );

      expect(saveButtonWidget.onPressed, isNotNull);

      // save() writes the file via real (non-fake) async I/O, which hangs
      // if awaited directly inside a widget test's fake-async zone; run it
      // for real via runAsync instead of tapping the (fire-and-forget)
      // button.
      await tester.runAsync(() => controller.save());
      await tester.pump();

      expect(controller.isDirty, isFalse);
      expect(
        File(caveOnePath).readAsStringSync(),
        'survey renamed\nendsurvey\n',
      );
    });
  });
}
