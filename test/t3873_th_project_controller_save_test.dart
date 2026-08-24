// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

import 'th_project_controller_test_aux.dart';
import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final THProjectController controller = MPLocator().thProjectController;

  Directory? tempDir;

  String canonicalPath(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  Future<void> waitForDebounce() => Future<void>.delayed(
    const Duration(milliseconds: mpProjectReparseDebounceMilliseconds + 250),
  );

  tearDown(() {
    controller.closeProject();
    final Directory? dir = tempDir;
    if ((dir != null) && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    tempDir = null;
  });

  group('THProjectController saving', () {
    test(
      'saveProjectFile writes edited .th content to disk and clears dirty state',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String caveOneCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_one.th'),
        );

        await controller.openProject(thconfigPath);
        await controller.reparseFile(
          filePath: caveOneCanonical,
          updatedContent: 'survey renamed_one\nendsurvey\n',
        );
        await waitForDebounce();

        expect(controller.isFileDirty(caveOneCanonical), isTrue);

        await controller.saveProjectFile(caveOneCanonical);

        expect(controller.isFileDirty(caveOneCanonical), isFalse);

        final String savedContent = utf8.decode(
          File(caveOneCanonical).readAsBytesSync(),
        );
        expect(savedContent, contains('renamed_one'));
      },
    );

    test(
      'saveAllModifiedFiles saves every dirty file and clears the set',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String caveOneCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_one.th'),
        );
        final String caveTwoCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_two.th'),
        );

        await controller.openProject(thconfigPath);
        await controller.reparseFile(
          filePath: caveOneCanonical,
          updatedContent: 'survey renamed_one\nendsurvey\n',
        );
        await controller.reparseFile(
          filePath: caveTwoCanonical,
          updatedContent: 'survey renamed_two\nendsurvey\n',
        );
        await waitForDebounce();

        expect(controller.hasUnsavedChanges, isTrue);

        await controller.saveAllModifiedFiles();

        expect(controller.hasUnsavedChanges, isFalse);
        expect(
          utf8.decode(File(caveOneCanonical).readAsBytesSync()),
          contains('renamed_one'),
        );
        expect(
          utf8.decode(File(caveTwoCanonical).readAsBytesSync()),
          contains('renamed_two'),
        );
      },
    );

    test(
      'saveProjectFile on a .th2 path with no open editor skips without throwing',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp('two-level');
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String passageCanonical = canonicalPath(
          p.join(tempDir!.path, 'passage.th2'),
        );

        await controller.openProject(thconfigPath);

        await controller.saveProjectFile(passageCanonical);

        expect(controller.isFileDirty(passageCanonical), isFalse);
      },
    );

    test(
      'saveProjectFile on an unknown path skips without throwing',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');

        await controller.openProject(thconfigPath);

        await controller.saveProjectFile(
          p.join(tempDir!.path, 'not_part_of_the_project.th'),
        );
      },
    );
  });
}
