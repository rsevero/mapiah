// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_as_result.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
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

  final MPLocator mpLocator = MPLocator();
  final THProjectController controller = mpLocator.thProjectController;

  Directory? tempDir;

  String canonicalPath(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  setUp(() {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();
  });

  tearDown(() {
    controller.closeProject();
    mpLocator.mpGeneralController.reset();
    final Directory? dir = tempDir;
    if ((dir != null) && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    tempDir = null;
  });

  group('THProjectController.saveTextProjectFileAs non-root', () {
    test(
      'moves a source file, rewrites the referencing thconfig, keeps the '
      'old file untouched on disk',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = canonicalPath(
          p.join(tempDir!.path, 'thconfig'),
        );
        final String caveOneCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_one.th'),
        );
        final String destination = canonicalPath(
          p.join(tempDir!.path, 'moved', 'cave_one.th'),
        );
        final String originalOldBytes = utf8.decode(
          File(caveOneCanonical).readAsBytesSync(),
        );
        Directory(p.dirname(destination)).createSync(recursive: true);

        await controller.openProject(thconfigPath);

        final int revision = controller.registerTextContentChange(
          canonicalPath: caveOneCanonical,
          content: 'survey one\nendsurvey\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );
        await controller.flushPendingReparse(
          canonicalPath: caveOneCanonical,
          expectedRevision: revision,
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );

        final THTextFileSaveAsResult result = await controller
            .saveTextProjectFileAs(
              oldCanonicalPath: caveOneCanonical,
              newCanonicalPath: destination,
              requestedRevision: revision,
              expectedProjectEpoch: controller.projectEpoch,
              expectedRootPath: controller.rootConfigPath,
            );

        expect(result.status, THTextFileSaveAsStatus.saved);
        expect(result.isRootChange, isFalse);

        // Old file retained on disk, byte-for-byte.
        expect(
          utf8.decode(File(caveOneCanonical).readAsBytesSync()),
          originalOldBytes,
        );

        // New file exists with the moved content.
        final String newContent = utf8.decode(
          File(destination).readAsBytesSync(),
        );
        expect(newContent, contains('survey one'));

        // Project graph: old path retired, new path tracked as a data node.
        expect(controller.nodeByCanonicalPath(caveOneCanonical), isNull);
        expect(
          controller.nodeByCanonicalPath(destination),
          isA<THDataFileNode>(),
        );
        expect(controller.isFileDirty(caveOneCanonical), isFalse);
        expect(controller.isFileDirty(destination), isFalse);

        // The referencing thconfig was rewritten (now points at the new
        // relative location) and is now dirty.
        expect(controller.isFileDirty(thconfigPath), isTrue);
        expect(
          controller.fileContentsCache[thconfigPath],
          contains('moved/cave_one.th'),
        );
        expect(
          controller.nodeByCanonicalPath(thconfigPath),
          isA<THConfigFileNode>(),
        );
      },
    );

    test(
      'destinationCollision when the target is already a project node',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = canonicalPath(
          p.join(tempDir!.path, 'thconfig'),
        );
        final String caveOneCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_one.th'),
        );
        final String caveTwoCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_two.th'),
        );

        await controller.openProject(thconfigPath);

        final THTextFileSaveAsResult result = await controller
            .saveTextProjectFileAs(
              oldCanonicalPath: caveOneCanonical,
              newCanonicalPath: caveTwoCanonical,
              requestedRevision: 0,
              expectedProjectEpoch: controller.projectEpoch,
              expectedRootPath: controller.rootConfigPath,
            );

        expect(result.status, THTextFileSaveAsStatus.destinationCollision);
        expect(controller.isFileDirty(caveOneCanonical), isFalse);
        expect(controller.projectErrors, isNotEmpty);
      },
    );

    test(
      'destinationCollision when the target is already an open standalone tab',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = canonicalPath(
          p.join(tempDir!.path, 'thconfig'),
        );
        final String caveOneCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_one.th'),
        );
        final String otherOpenPath = canonicalPath(
          p.join(tempDir!.path, 'unrelated_open_tab.th'),
        );

        await controller.openProject(thconfigPath);
        mpLocator.mpGeneralController.getTextEditorController(otherOpenPath);

        final THTextFileSaveAsResult result = await controller
            .saveTextProjectFileAs(
              oldCanonicalPath: caveOneCanonical,
              newCanonicalPath: otherOpenPath,
              requestedRevision: 0,
              expectedProjectEpoch: controller.projectEpoch,
              expectedRootPath: controller.rootConfigPath,
            );

        expect(result.status, THTextFileSaveAsStatus.destinationCollision);
      },
    );

    test('unknownPath for a source outside the project', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp(
        'multiple-sources',
      );
      final String thconfigPath = canonicalPath(
        p.join(tempDir!.path, 'thconfig'),
      );

      await controller.openProject(thconfigPath);

      final THTextFileSaveAsResult result = await controller
          .saveTextProjectFileAs(
            oldCanonicalPath: p.join(
              tempDir!.path,
              'not_part_of_the_project.th',
            ),
            newCanonicalPath: p.join(tempDir!.path, 'moved', 'target.th'),
            requestedRevision: 0,
            expectedProjectEpoch: controller.projectEpoch,
            expectedRootPath: controller.rootConfigPath,
          );

      expect(result.status, THTextFileSaveAsStatus.unknownPath);
    });

    test(
      'projectChangedBeforeWrite when the captured epoch is stale',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = canonicalPath(
          p.join(tempDir!.path, 'thconfig'),
        );
        final String caveOneCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_one.th'),
        );

        await controller.openProject(thconfigPath);

        final int staleEpoch = controller.projectEpoch;
        final String staleRoot = controller.rootConfigPath;

        controller.closeProject();

        final THTextFileSaveAsResult result = await controller
            .saveTextProjectFileAs(
              oldCanonicalPath: caveOneCanonical,
              newCanonicalPath: p.join(tempDir!.path, 'moved', 'target.th'),
              requestedRevision: 0,
              expectedProjectEpoch: staleEpoch,
              expectedRootPath: staleRoot,
            );

        expect(
          result.status,
          THTextFileSaveAsStatus.projectChangedBeforeWrite,
        );
      },
    );
  });

  group('THProjectController.saveTextProjectFileAs root', () {
    test(
      'moves the root thconfig, updates rootConfigPath, preserves other '
      'dirty buffers',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = canonicalPath(
          p.join(tempDir!.path, 'thconfig'),
        );
        final String caveOneCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_one.th'),
        );
        final String destination = canonicalPath(
          p.join(tempDir!.path, 'moved_thconfig'),
        );

        await controller.openProject(thconfigPath);

        // An unrelated dirty buffer that must survive the rebuild.
        await THProjectControllerTestAux.editAndFlush(
          controller,
          filePath: caveOneCanonical,
          content: 'survey renamed_one\nendsurvey\n',
        );
        expect(controller.isFileDirty(caveOneCanonical), isTrue);

        final THTextFileSaveAsResult result = await controller
            .saveTextProjectFileAs(
              oldCanonicalPath: thconfigPath,
              newCanonicalPath: destination,
              requestedRevision: 0,
              expectedProjectEpoch: controller.projectEpoch,
              expectedRootPath: controller.rootConfigPath,
            );

        expect(result.status, THTextFileSaveAsStatus.saved);
        expect(result.isRootChange, isTrue);
        expect(controller.rootConfigPath, destination);
        expect(controller.isFileDirty(caveOneCanonical), isTrue);
        expect(
          utf8.decode(File(caveOneCanonical).readAsBytesSync()),
          isNot(contains('renamed_one')),
        );
      },
    );
  });

  group('THProjectController.saveTextProjectFileAs failure rollback', () {
    test(
      'rebuildFailed leaves the destination on disk but the project '
      'identity fully unchanged',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = canonicalPath(
          p.join(tempDir!.path, 'thconfig'),
        );
        final String caveOneCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_one.th'),
        );
        final String destination = canonicalPath(
          p.join(tempDir!.path, 'moved', 'cave_one.th'),
        );
        Directory(p.dirname(destination)).createSync(recursive: true);

        final FakeProjectOperations fake = FakeProjectOperations();
        final THProjectController fakeController = THProjectController(
          operations: fake.build(),
        );

        await fakeController.openProject(thconfigPath);

        fake.loadError = StateError('forced rebuild failure');

        final THTextFileSaveAsResult result = await fakeController
            .saveTextProjectFileAs(
              oldCanonicalPath: caveOneCanonical,
              newCanonicalPath: destination,
              requestedRevision: 0,
              expectedProjectEpoch: fakeController.projectEpoch,
              expectedRootPath: fakeController.rootConfigPath,
            );

        expect(result.status, THTextFileSaveAsStatus.rebuildFailed);
        // Bytes reached disk (accepted residue) ...
        expect(File(destination).existsSync(), isTrue);
        // ... but the live project identity is unchanged.
        expect(fakeController.rootConfigPath, thconfigPath);
        expect(
          fakeController.nodeByCanonicalPath(caveOneCanonical),
          isNotNull,
        );
        expect(fakeController.isFileDirty(caveOneCanonical), isFalse);

        fakeController.closeProject();
      },
    );

    test(
      'writeFailed leaves the old file and project state untouched',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = canonicalPath(
          p.join(tempDir!.path, 'thconfig'),
        );
        final String caveOneCanonical = canonicalPath(
          p.join(tempDir!.path, 'cave_one.th'),
        );
        final String destination = canonicalPath(
          p.join(tempDir!.path, 'moved', 'cave_one.th'),
        );

        final FakeProjectOperations fake = FakeProjectOperations();
        final THProjectController fakeController = THProjectController(
          operations: fake.build(),
        );

        await fakeController.openProject(thconfigPath);

        fake.writeError = const FileSystemException('denied');

        final THTextFileSaveAsResult result = await fakeController
            .saveTextProjectFileAs(
              oldCanonicalPath: caveOneCanonical,
              newCanonicalPath: destination,
              requestedRevision: 0,
              expectedProjectEpoch: fakeController.projectEpoch,
              expectedRootPath: fakeController.rootConfigPath,
            );

        expect(result.status, THTextFileSaveAsStatus.writeFailed);
        expect(File(destination).existsSync(), isFalse);
        expect(
          fakeController.nodeByCanonicalPath(caveOneCanonical),
          isNotNull,
        );
        expect(fakeController.isFileDirty(caveOneCanonical), isFalse);

        fakeController.closeProject();
      },
    );
  });
}
