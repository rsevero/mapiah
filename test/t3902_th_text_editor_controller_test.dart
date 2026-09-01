// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
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

  // The controller's own debounce triggers THProjectController.reparseFile,
  // which then runs its own debounce before the actual re-parse, so the
  // wait must cover both.
  Future<void> waitForDebounce() => Future<void>.delayed(
    const Duration(
      milliseconds:
          mpTextEditorReparseDebounceMilliseconds +
          mpProjectReparseDebounceMilliseconds +
          250,
    ),
  );

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

  group('THTextEditorController', () {
    test('loadFile reads from disk when nothing is cached', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );

      final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');
      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );
      activeController = controller;

      await controller.loadFile(caveOnePath);

      expect(controller.canonicalPath, canonicalPath(caveOnePath));
      expect(controller.content, 'survey one\nendsurvey\n');
      expect(controller.isDirty, isFalse);
      expect(controller.cursorLine, 0);
      expect(controller.cursorColumn, 0);
    });

    test(
      'loadFile adopts the project-owned pending content of a tracked dirty file',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );

        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');
        final String caveOneCanonical = canonicalPath(caveOnePath);

        await mpLocator.thProjectController.openProject(thconfigPath);

        // A pending, unsaved edit registered on the project controller.
        final int revision = mpLocator.thProjectController
            .registerTextContentChange(
              canonicalPath: caveOneCanonical,
              content: 'survey cached\nendsurvey',
              expectedProjectEpoch:
                  mpLocator.thProjectController.projectEpoch,
              expectedRootPath:
                  mpLocator.thProjectController.rootConfigPath,
            );

        final THTextEditorController controller = THTextEditorController(
          projectController: mpLocator.thProjectController,
        );
        activeController = controller;

        await controller.loadFile(caveOnePath);

        expect(controller.content, 'survey cached\nendsurvey');
        expect(controller.isDirty, isTrue);
        expect(controller.observedRevision, revision);
      },
    );

    test('setContent marks the controller dirty', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );
      activeController = controller;

      await controller.loadFile(p.join(tempDir!.path, 'cave_one.th'));
      expect(controller.isDirty, isFalse);

      controller.setContent('survey renamed\nendsurvey\n');
      expect(controller.isDirty, isTrue);
      expect(controller.content, 'survey renamed\nendsurvey\n');
    });

    test('rapid edits collapse into a single debounced reparseFile call', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );

      final String thconfigPath = p.join(tempDir!.path, 'thconfig');
      final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');
      final String caveOneCanonical = canonicalPath(caveOnePath);

      await mpLocator.thProjectController.openProject(thconfigPath);

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );
      activeController = controller;

      await controller.loadFile(caveOnePath);

      controller.setContent('survey re\nendsurvey');
      controller.setContent('survey ren\nendsurvey');
      controller.setContent('survey renamed\nendsurvey\n');
      await waitForDebounce();

      expect(
        mpLocator.thProjectController.fileContentsCache[caveOneCanonical],
        'survey renamed\nendsurvey\n',
      );
    });

    test('save calls THProjectController.saveProjectFile and clears dirty', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );

      final String thconfigPath = p.join(tempDir!.path, 'thconfig');
      final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');

      await mpLocator.thProjectController.openProject(thconfigPath);

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );
      activeController = controller;

      await controller.loadFile(caveOnePath);
      controller.setContent('survey renamed\nendsurvey\n');
      await waitForDebounce();

      await controller.save();

      expect(controller.isDirty, isFalse);
      expect(
        File(caveOnePath).readAsStringSync(),
        'survey renamed\nendsurvey\n',
      );
    });

    test('revert reloads the last cached content and clears dirty state', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );

      final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');
      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );
      activeController = controller;

      await controller.loadFile(caveOnePath);
      controller.setContent('survey renamed\nendsurvey\n');
      expect(controller.isDirty, isTrue);

      await controller.revert();

      expect(controller.isDirty, isFalse);
      expect(controller.content, 'survey one\nendsurvey\n');
    });

    test('setCursorPosition updates cursorLine and cursorColumn', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );
      activeController = controller;

      await controller.loadFile(p.join(tempDir!.path, 'cave_one.th'));
      controller.setCursorPosition(line: 1, column: 3);

      expect(controller.cursorLine, 1);
      expect(controller.cursorColumn, 3);
    });

    test('diagnostics only include errors for this file', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp('missing-file');

      final String thconfigPath = p.join(tempDir!.path, 'thconfig');
      final String caveOnePath = p.join(tempDir!.path, 'cave.th');
      final String thconfigCanonical = canonicalPath(thconfigPath);

      await mpLocator.thProjectController.openProject(thconfigPath);

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
      );
      activeController = controller;

      await controller.loadFile(caveOnePath);

      expect(
        mpLocator.thProjectController.projectErrors.any(
          (error) => error.filePath == thconfigCanonical,
        ),
        isTrue,
        reason: 'thconfig itself references a missing source file',
      );
      expect(
        controller.diagnostics,
        isEmpty,
        reason: 'cave.th itself has no errors of its own',
      );
    });
  });
}
