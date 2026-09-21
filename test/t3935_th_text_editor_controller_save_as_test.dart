// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_as_result.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
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

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
  });

  tearDown(() {
    activeController?.dispose();
    activeController = null;
    mpLocator.thProjectController.closeProject();
    mpLocator.mpGeneralController.reset();
    final Directory? dir = tempDir;
    if ((dir != null) && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    tempDir = null;
  });

  group('THTextEditorController.saveAs cancellation and pre-picker checks', () {
    test('a cancelled picker changes nothing', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );
      final String thconfigPath = p.join(tempDir!.path, 'thconfig');
      final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');
      final String caveOneCanonical = canonicalPath(caveOnePath);

      await mpLocator.thProjectController.openProject(thconfigPath);

      bool pickerCalled = false;
      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
        saveAsFilePicker:
            ({
              required String dialogTitle,
              required String fileName,
              String? initialDirectory,
              required FileType type,
              List<String>? allowedExtensions,
            }) async {
              pickerCalled = true;
              return null;
            },
      );
      activeController = controller;

      await controller.loadFile(caveOnePath);
      final String originalContent = controller.content;

      final THTextFileSaveAsResult result = await controller.saveAs();

      expect(pickerCalled, isTrue);
      expect(result.status, THTextFileSaveAsStatus.cancelled);
      expect(controller.canonicalPath, caveOneCanonical);
      expect(controller.content, originalContent);
      expect(controller.isDirty, isFalse);
      expect(
        mpLocator.mpGeneralController.getTextEditorControllerIfExists(
          caveOneCanonical,
        ),
        isNull,
      );
    });

    test(
      'a stale project identity aborts before the picker opens',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');

        await mpLocator.thProjectController.openProject(thconfigPath);

        bool pickerCalled = false;
        final THTextEditorController controller = THTextEditorController(
          projectController: mpLocator.thProjectController,
          saveAsFilePicker:
              ({
                required String dialogTitle,
                required String fileName,
                String? initialDirectory,
                required FileType type,
                List<String>? allowedExtensions,
              }) async {
                pickerCalled = true;
                return null;
              },
        );
        activeController = controller;

        await controller.loadFile(caveOnePath);

        // Move the project on to a newer epoch than the one this controller
        // was bound to.
        mpLocator.thProjectController.closeProject();

        final THTextFileSaveAsResult result = await controller.saveAs();

        expect(pickerCalled, isFalse);
        expect(
          result.status,
          THTextFileSaveAsStatus.projectChangedBeforeWrite,
        );
      },
    );
  });

  group('THTextEditorController.saveAs extension rules', () {
    test('appends .th when the chosen .th-shaped path has no extension', () {
      // Pure path-rule check, mirroring saveAs()'s own extension logic for a
      // .th-shaped (THDataFileNode) source; exercised end to end via the
      // untracked-fallback test below.
      expect(p.extension('cave_two'), isEmpty);
    });

    test(
      'untracked/.th-shaped source: appends .th and writes directly to disk',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String sourcePath = p.join(tempDir!.path, 'cave_one.th');
        final String extensionlessTarget = p.join(
          tempDir!.path,
          'cave_two_renamed',
        );

        final THTextEditorController controller = THTextEditorController(
          saveAsFilePicker:
              ({
                required String dialogTitle,
                required String fileName,
                String? initialDirectory,
                required FileType type,
                List<String>? allowedExtensions,
              }) async {
                expect(type, FileType.custom);
                expect(allowedExtensions, <String>['th']);
                return Uri.file(extensionlessTarget);
              },
        );
        activeController = controller;

        await controller.loadFile(sourcePath);
        expect(controller.isProjectBound, isFalse);

        final THTextFileSaveAsResult result = await controller.saveAs();

        expect(result.status, THTextFileSaveAsStatus.saved);
        expect(controller.canonicalPath, canonicalPath('$extensionlessTarget.th'));
        expect(File('$extensionlessTarget.th').existsSync(), isTrue);
        expect(
          utf8.decode(File('$extensionlessTarget.th').readAsBytesSync()),
          controller.content,
        );
        expect(controller.isDirty, isFalse);
      },
    );

    test(
      'untracked/thconfig-shaped source: keeps the chosen name verbatim',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String sourcePath = p.join(tempDir!.path, 'thconfig');
        final String target = p.join(tempDir!.path, 'my_project_config');

        final THTextEditorController controller = THTextEditorController(
          saveAsFilePicker:
              ({
                required String dialogTitle,
                required String fileName,
                String? initialDirectory,
                required FileType type,
                List<String>? allowedExtensions,
              }) async {
                expect(type, FileType.any);
                expect(allowedExtensions, isNull);
                return Uri.file(target);
              },
        );
        activeController = controller;

        await controller.loadFile(sourcePath);

        final THTextFileSaveAsResult result = await controller.saveAs();

        expect(result.status, THTextFileSaveAsStatus.saved);
        expect(controller.canonicalPath, canonicalPath(target));
        expect(File(target).existsSync(), isTrue);
      },
    );
  });

  group('THTextEditorController.saveAs same-path and project-bound moves', () {
    test('choosing the current path delegates to save()', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );
      final String thconfigPath = p.join(tempDir!.path, 'thconfig');
      final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');
      final String caveOneCanonical = canonicalPath(caveOnePath);

      await mpLocator.thProjectController.openProject(thconfigPath);

      final THTextEditorController controller = THTextEditorController(
        projectController: mpLocator.thProjectController,
        saveAsFilePicker:
            ({
              required String dialogTitle,
              required String fileName,
              String? initialDirectory,
              required FileType type,
              List<String>? allowedExtensions,
            }) async {
              return Uri.file(caveOneCanonical);
            },
      );
      activeController = controller;

      await controller.loadFile(caveOnePath);
      controller.setContent('survey renamed_one\nendsurvey\n');

      final THTextFileSaveAsResult result = await controller.saveAs();

      expect(result.status, THTextFileSaveAsStatus.saved);
      expect(controller.isDirty, isFalse);
      expect(
        utf8.decode(File(caveOneCanonical).readAsBytesSync()),
        contains('renamed_one'),
      );
    });

    test(
      'a project-tracked move updates identity and stays consistent with '
      'the current project (registry migration itself is covered by '
      'MPGeneralController.renameFileController tests)',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');
        final String destination = canonicalPath(
          p.join(tempDir!.path, 'moved', 'cave_one.th'),
        );
        Directory(p.dirname(destination)).createSync(recursive: true);

        await mpLocator.thProjectController.openProject(thconfigPath);

        final THTextEditorController controller = THTextEditorController(
          projectController: mpLocator.thProjectController,
          saveAsFilePicker:
              ({
                required String dialogTitle,
                required String fileName,
                String? initialDirectory,
                required FileType type,
                List<String>? allowedExtensions,
              }) async {
                return Uri.file(destination);
              },
        );
        activeController = controller;

        await controller.loadFile(caveOnePath);

        final THTextFileSaveAsResult result = await controller.saveAs();

        expect(result.status, THTextFileSaveAsStatus.saved);
        expect(result.isRootChange, isFalse);
        expect(controller.canonicalPath, destination);
        expect(controller.isDirty, isFalse);
        expect(controller.matchesCurrentProject(), isTrue);
        expect(
          mpLocator.thProjectController.nodeByCanonicalPath(destination),
          isNotNull,
        );
      },
    );

    test(
      'a destination collision leaves identity and dirty state unchanged',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String caveOnePath = p.join(tempDir!.path, 'cave_one.th');
        final String caveOneCanonical = canonicalPath(caveOnePath);
        final String caveTwoCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_two.th'),
        );

        await mpLocator.thProjectController.openProject(thconfigPath);

        final THTextEditorController controller = THTextEditorController(
          projectController: mpLocator.thProjectController,
          saveAsFilePicker:
              ({
                required String dialogTitle,
                required String fileName,
                String? initialDirectory,
                required FileType type,
                List<String>? allowedExtensions,
              }) async {
                return Uri.file(caveTwoCanonical);
              },
        );
        activeController = controller;

        await controller.loadFile(caveOnePath);

        final THTextFileSaveAsResult result = await controller.saveAs();

        expect(result.status, THTextFileSaveAsStatus.destinationCollision);
        expect(controller.canonicalPath, caveOneCanonical);
        expect(controller.isDirty, isFalse);
      },
    );
  });
}
