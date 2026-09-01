// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

import 'th_project_controller_operations_fake.dart';
import 'th_project_controller_test_aux.dart';
import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  Directory? tempDir;

  String canonical(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  setUp(() {
    MPLocator().appLocalizations = AppLocalizationsEn();
  });

  tearDown(() {
    final Directory? dir = tempDir;
    if ((dir != null) && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    tempDir = null;
  });

  Future<(THProjectController, Directory)> openMultipleSources({
    FakeProjectOperations? fake,
  }) async {
    tempDir = THProjectControllerTestAux.copyFixtureToTemp('multiple-sources');
    final THProjectController controller = THProjectController(
      operations: fake?.build(),
    );
    await controller.openProject(p.join(tempDir!.path, 'thconfig'));

    return (controller, tempDir!);
  }

  group('generic text save', () {
    test(
      'snapshots the revision and drains reparse without an editor timer',
      () async {
        final (THProjectController controller, Directory dir) =
            await openMultipleSources();
        final String caveOne = canonical(p.join(dir.path, 'cave_one.th'));

        // No editor involved: register content straight on the controller.
        controller.registerTextContentChange(
          canonicalPath: caveOne,
          content: 'survey generic_saved\nendsurvey\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );

        final THProjectFileSaveResult result = await controller.saveProjectFile(
          caveOne,
        );

        expect(result, isA<THProjectTextFileSaveResult>());
        expect(result.isComplete, isTrue);
        expect(
          (result as THProjectTextFileSaveResult).textResult.status,
          THTextFileSaveStatus.saved,
        );
        expect(controller.isFileDirty(caveOne), isFalse);
        expect(
          utf8.decode(File(caveOne).readAsBytesSync()),
          contains('generic_saved'),
        );
      },
    );

    test(
      'a late reparse callback for an already-saved revision is idempotent',
      () async {
        final (THProjectController controller, Directory dir) =
            await openMultipleSources();
        final String caveOne = canonical(p.join(dir.path, 'cave_one.th'));

        final int revision = controller.registerTextContentChange(
          canonicalPath: caveOne,
          content: 'survey saved_then_stale\nendsurvey\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );
        await controller.saveProjectFile(caveOne);
        expect(controller.isFileDirty(caveOne), isFalse);

        // A stale editor debounce fires after the save with the same revision.
        await controller.reparseFile(
          filePath: caveOne,
          updatedContent: 'survey saved_then_stale\nendsurvey\n',
          revision: revision,
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );

        expect(controller.isFileDirty(caveOne), isFalse);
      },
    );

    test('an unknown path returns a rejected result', () async {
      final (THProjectController controller, Directory dir) =
          await openMultipleSources();

      final THProjectFileSaveResult result = await controller.saveProjectFile(
        p.join(dir.path, 'not_in_project.th'),
      );

      expect(result, isA<THProjectRejectedFileSaveResult>());
      expect(
        (result as THProjectRejectedFileSaveResult).reason,
        THTextFileSaveStatus.unknownPath,
      );
      expect(result.isComplete, isFalse);
    });

    test('a .th2 path with no open editor returns a TH2 noOpenEditor result', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp('two-level');
      final THProjectController controller = THProjectController();
      await controller.openProject(p.join(tempDir!.path, 'thconfig'));

      final THProjectFileSaveResult result = await controller.saveProjectFile(
        p.join(tempDir!.path, 'passage.th2'),
      );

      expect(result, isA<THProjectTH2FileSaveResult>());
      expect(
        (result as THProjectTH2FileSaveResult).status,
        TH2FileSaveStatus.noOpenEditor,
      );
      expect(result.isComplete, isFalse);
    });
  });

  group('saveAllModifiedFiles', () {
    test('empty target set returns an empty, complete aggregate', () async {
      final (THProjectController controller, _) = await openMultipleSources();

      final THSaveAllModifiedFilesResult result = await controller
          .saveAllModifiedFiles();

      expect(result.results, isEmpty);
      expect(result.isComplete, isTrue);
      expect(result.remainingDirtyPaths, isEmpty);
    });

    test(
      'processes a sorted descriptor snapshot and continues past a failure',
      () async {
        final fake = FakeProjectOperations();
        final (THProjectController controller, Directory dir) =
            await openMultipleSources(fake: fake);
        final String caveOne = canonical(p.join(dir.path, 'cave_one.th'));
        final String caveTwo = canonical(p.join(dir.path, 'cave_two.th'));

        controller.registerTextContentChange(
          canonicalPath: caveOne,
          content: 'survey one_saved\nendsurvey\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );
        controller.registerTextContentChange(
          canonicalPath: caveTwo,
          content: 'survey two_saved\nendsurvey\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );

        // Make only cave_two's write fail.
        fake.writeErrorPaths.add(caveTwo);

        final THSaveAllModifiedFilesResult result = await controller
            .saveAllModifiedFiles();

        expect(result.results, hasLength(2));
        // Sorted order: paths compared lexicographically.
        final List<String> paths = <String>[caveOne, caveTwo]..sort();
        expect(
          result.results
              .map((THProjectFileSaveResult r) => r.canonicalPath)
              .toList(),
          paths,
        );
        expect(result.isComplete, isFalse);
        expect(result.remainingDirtyPaths, contains(caveTwo));
        expect(result.remainingDirtyPaths, isNot(contains(caveOne)));
      },
    );
  });
}

