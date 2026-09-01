// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_project_reparse_flush_result.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_revert_result.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
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

  setUp(() {
    MPLocator().appLocalizations = AppLocalizationsEn();
  });

  String canonical(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  tearDown(() {
    final Directory? dir = tempDir;
    if ((dir != null) && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    tempDir = null;
  });

  Future<(THProjectController, String, String)> openMultipleSources({
    FakeProjectOperations? fake,
  }) async {
    tempDir = THProjectControllerTestAux.copyFixtureToTemp('multiple-sources');
    final String thconfigPath = p.join(tempDir!.path, 'thconfig');
    final String caveOne = canonical(p.join(tempDir!.path, 'cave_one.th'));
    final THProjectController controller = THProjectController(
      operations: fake?.build(),
    );

    await controller.openProject(thconfigPath);

    return (controller, canonical(thconfigPath), caveOne);
  }

  group('atomic revision allocation', () {
    test(
      'two controllers from the same observed baseline get distinct revisions',
      () async {
        final (THProjectController controller, _, String caveOne) =
            await openMultipleSources();

        // Both "controllers" observe baseline revision 0 for caveOne.
        final int revA = controller.registerTextContentChange(
          canonicalPath: caveOne,
          content: 'survey a\nendsurvey\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );
        final int revB = controller.registerTextContentChange(
          canonicalPath: caveOne,
          content: 'survey b\nendsurvey\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );

        expect(revA, 1);
        expect(revB, 2);
        expect(revA, isNot(revB));
      },
    );

    test('a revision is never reused after a successful save', () async {
      final (THProjectController controller, String root, String caveOne) =
          await openMultipleSources();

      final int firstRevision = controller.registerTextContentChange(
        canonicalPath: caveOne,
        content: 'survey first\nendsurvey\n',
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );
      await controller.flushPendingReparse(
        canonicalPath: caveOne,
        expectedRevision: firstRevision,
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );
      final THTextFileSaveResult saved = await controller.saveTextProjectFile(
        canonicalPath: caveOne,
        requestedRevision: firstRevision,
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );
      expect(saved.status, THTextFileSaveStatus.saved);

      final int secondRevision = controller.registerTextContentChange(
        canonicalPath: caveOne,
        content: 'survey second\nendsurvey\n',
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );

      expect(secondRevision, greaterThan(firstRevision));
    });
  });

  group('loadFile adoption', () {
    test(
      'adopts project-owned pending content/revision/dirty together',
      () async {
        final (THProjectController controller, _, String caveOne) =
            await openMultipleSources();

        final int revision = controller.registerTextContentChange(
          canonicalPath: caveOne,
          content: 'survey pending\nendsurvey\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );

        final THTextEditorController editor = THTextEditorController(
          projectController: controller,
        );
        addTearDown(editor.dispose);

        await editor.loadFile(caveOne);

        expect(editor.content, 'survey pending\nendsurvey\n');
        expect(editor.isDirty, isTrue);
        expect(editor.observedRevision, revision);
        expect(editor.isProjectBound, isTrue);
      },
    );

    test('disk fallback for an untracked path uses revision 0 and clean', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp('multiple-sources');
      final THProjectController controller = THProjectController();
      final THTextEditorController editor = THTextEditorController(
        projectController: controller,
      );
      addTearDown(editor.dispose);

      await editor.loadFile(p.join(tempDir!.path, 'cave_one.th'));

      expect(editor.content, 'survey one\nendsurvey\n');
      expect(editor.isDirty, isFalse);
      expect(editor.observedRevision, 0);
      expect(editor.isProjectBound, isFalse);
    });
  });

  group('flush before save across both debounce layers', () {
    test(
      'editor edit then save reparses before serialization',
      () async {
        final (THProjectController controller, _, String caveOne) =
            await openMultipleSources();

        final THTextEditorController editor = THTextEditorController(
          projectController: controller,
        );
        addTearDown(editor.dispose);
        await editor.loadFile(caveOne);

        editor.setContent('survey renamed_immediately\nendsurvey\n');
        // Do not wait for either debounce; save() must drain both.
        final THTextFileSaveResult result = await editor.save();

        expect(result.status, THTextFileSaveStatus.saved);
        expect(editor.isDirty, isFalse);
        expect(
          utf8.decode(File(caveOne).readAsBytesSync()),
          contains('renamed_immediately'),
        );
      },
    );

    test('editing the root thconfig serializes the in-memory revision', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp('multiple-sources');
      final String thconfigPath = p.join(tempDir!.path, 'thconfig');
      final String thconfigCanonical = canonical(thconfigPath);
      final THProjectController controller = THProjectController();
      await controller.openProject(thconfigPath);

      final THTextEditorController rootEditor = THTextEditorController(
        projectController: controller,
      );
      final THTextEditorController otherEditor = THTextEditorController(
        projectController: controller,
      );
      addTearDown(rootEditor.dispose);
      addTearDown(otherEditor.dispose);

      await otherEditor.loadFile(
        canonical(p.join(tempDir!.path, 'cave_two.th')),
      );
      otherEditor.setContent('survey untouched_but_dirty\nendsurvey\n');

      await rootEditor.loadFile(thconfigCanonical);
      rootEditor.setContent('encoding UTF-8\nsource cave_one.th\n');

      final THTextFileSaveResult result = await rootEditor.save();

      expect(result.status, THTextFileSaveStatus.saved);
      expect(
        utf8.decode(File(thconfigCanonical).readAsBytesSync()),
        contains('source cave_one.th'),
      );
      expect(
        (controller.projectRootNode! as THConfigFileNode).children
            .whereType<THDataFileNode>(),
        hasLength(1),
      );
      // The other editor's unsaved content survived the root rebuild.
      expect(otherEditor.isDirty, isTrue);
      expect(
        controller.isFileDirty(canonical(p.join(tempDir!.path, 'cave_two.th'))),
        isTrue,
      );
    });
  });

  group('explicit save statuses', () {
    test('unchanged loaded revision returns alreadySaved without I/O', () async {
      final fake = FakeProjectOperations();
      final (THProjectController controller, String root, String caveOne) =
          await openMultipleSources(fake: fake);

      final THTextFileSaveResult result = await controller.saveTextProjectFile(
        canonicalPath: caveOne,
        requestedRevision: 0,
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );

      expect(result.status, THTextFileSaveStatus.alreadySaved);
      expect(result.writtenRevision, isNull);
      expect(fake.writeInvoked, isFalse);
    });

    test('unknown path returns unknownPath', () async {
      final (THProjectController controller, String root, _) =
          await openMultipleSources();

      final THTextFileSaveResult result = await controller.saveTextProjectFile(
        canonicalPath: canonical(p.join(tempDir!.path, 'nope.th')),
        requestedRevision: 0,
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );

      expect(result.status, THTextFileSaveStatus.unknownPath);
    });

    test('serialization failure reaches only serializationFailed', () async {
      final fake = FakeProjectOperations();
      final (THProjectController controller, String root, String caveOne) =
          await openMultipleSources(fake: fake);

      final int revision = controller.registerTextContentChange(
        canonicalPath: caveOne,
        content: 'survey x\nendsurvey\n',
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );
      await controller.flushPendingReparse(
        canonicalPath: caveOne,
        expectedRevision: revision,
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );

      fake.serializeError = StateError('boom');

      final THTextFileSaveResult result = await controller.saveTextProjectFile(
        canonicalPath: caveOne,
        requestedRevision: revision,
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );

      expect(result.status, THTextFileSaveStatus.serializationFailed);
      expect(fake.writeInvoked, isFalse);
    });

    test('write failure reaches only writeFailed', () async {
      final fake = FakeProjectOperations();
      final (THProjectController controller, String root, String caveOne) =
          await openMultipleSources(fake: fake);

      final int revision = controller.registerTextContentChange(
        canonicalPath: caveOne,
        content: 'survey y\nendsurvey\n',
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );
      await controller.flushPendingReparse(
        canonicalPath: caveOne,
        expectedRevision: revision,
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );

      fake.writeError = const FileSystemException('denied');

      final THTextFileSaveResult result = await controller.saveTextProjectFile(
        canonicalPath: caveOne,
        requestedRevision: revision,
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );

      expect(result.status, THTextFileSaveStatus.writeFailed);
      expect(controller.isFileDirty(caveOne), isTrue);
    });

    test(
      'a gated write is never invoked when the project changed before write',
      () async {
        final fake = FakeProjectOperations();
        final (THProjectController controller, String root, String caveOne) =
            await openMultipleSources(fake: fake);

        final int revision = controller.registerTextContentChange(
          canonicalPath: caveOne,
          content: 'survey pre\nendsurvey\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: root,
        );
        await controller.flushPendingReparse(
          canonicalPath: caveOne,
          expectedRevision: revision,
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: root,
        );

        // Simulate the project moving on before the save is requested.
        final int staleEpoch = controller.projectEpoch;
        controller.closeProject();

        final THTextFileSaveResult result = await controller.saveTextProjectFile(
          canonicalPath: caveOne,
          requestedRevision: revision,
          expectedProjectEpoch: staleEpoch,
          expectedRootPath: root,
        );

        expect(
          result.status,
          THTextFileSaveStatus.projectChangedBeforeWrite,
        );
        expect(fake.writeInvoked, isFalse);
      },
    );

    test(
      'a write that started before a project change reports '
      'writtenAfterProjectChange',
      () async {
        final fake = FakeProjectOperations();
        final gate = MPAsyncGate();
        fake.writeGate = gate;

        final (THProjectController controller, String root, String caveOne) =
            await openMultipleSources(fake: fake);

        final int revision = controller.registerTextContentChange(
          canonicalPath: caveOne,
          content: 'survey inflight\nendsurvey\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: root,
        );
        await controller.flushPendingReparse(
          canonicalPath: caveOne,
          expectedRevision: revision,
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: root,
        );

        final int epoch = controller.projectEpoch;
        final Future<THTextFileSaveResult> pending = controller
            .saveTextProjectFile(
              canonicalPath: caveOne,
              requestedRevision: revision,
              expectedProjectEpoch: epoch,
              expectedRootPath: root,
            );

        await gate.started;
        controller.closeProject();
        gate.release();

        final THTextFileSaveResult result = await pending;

        expect(
          result.status,
          THTextFileSaveStatus.writtenAfterProjectChange,
        );
        expect(result.writtenRevision, revision);
        expect(fake.writeInvoked, isTrue);
      },
    );
  });

  group('revision-aware revert', () {
    test('reverting a tracked dirty file publishes a fresh clean revision', () async {
      final (THProjectController controller, String root, String caveOne) =
          await openMultipleSources();

      final int revision = controller.registerTextContentChange(
        canonicalPath: caveOne,
        content: 'survey dirty\nendsurvey\n',
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );

      final THTextFileRevertResult result = await controller
          .revertTextProjectFile(
            canonicalPath: caveOne,
            requestedRevision: revision,
            expectedProjectEpoch: controller.projectEpoch,
            expectedRootPath: root,
          );

      expect(result.status, THTextFileRevertStatus.reverted);
      expect(result.reservedRevision, greaterThan(revision));
      expect(result.snapshot!.isDirty, isFalse);
      expect(result.snapshot!.content, 'survey one\nendsurvey\n');
      expect(controller.isFileDirty(caveOne), isFalse);
    });

    test('revert preserves the pending edit when the disk read fails', () async {
      final fake = FakeProjectOperations();
      final (THProjectController controller, String root, String caveOne) =
          await openMultipleSources(fake: fake);

      final int revision = controller.registerTextContentChange(
        canonicalPath: caveOne,
        content: 'survey keep_me\nendsurvey\n',
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: root,
      );

      fake.readError = const FileSystemException('unreadable');

      final THTextFileRevertResult result = await controller
          .revertTextProjectFile(
            canonicalPath: caveOne,
            requestedRevision: revision,
            expectedProjectEpoch: controller.projectEpoch,
            expectedRootPath: root,
          );

      expect(result.status, THTextFileRevertStatus.readFailed);
      expect(controller.isFileDirty(caveOne), isTrue);
      expect(controller.fileContentsCache[caveOne], 'survey keep_me\nendsurvey\n');
    });
  });

  group('full reparse failure', () {
    test('a failed full reparse preserves the tree and dirty state', () async {
      final fake = FakeProjectOperations();
      tempDir = THProjectControllerTestAux.copyFixtureToTemp('multiple-sources');
      final String thconfigPath = p.join(tempDir!.path, 'thconfig');
      final String thconfigCanonical = canonical(thconfigPath);
      final THProjectController controller = THProjectController(
        operations: fake.build(),
      );
      await controller.openProject(thconfigPath);

      final int childCountBefore =
          (controller.projectRootNode! as THConfigFileNode).children.length;

      final int revision = controller.registerTextContentChange(
        canonicalPath: thconfigCanonical,
        content: 'encoding UTF-8\nsource cave_one.th\n',
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: controller.rootConfigPath,
      );

      fake.loadError = StateError('parser exploded');

      final THProjectReparseFlushResult flush = await controller
          .flushPendingReparse(
            canonicalPath: thconfigCanonical,
            expectedRevision: revision,
            expectedProjectEpoch: controller.projectEpoch,
            expectedRootPath: controller.rootConfigPath,
          );

      expect(flush.status, THProjectReparseFlushStatus.failed);
      expect(
        (controller.projectRootNode! as THConfigFileNode).children.length,
        childCountBefore,
      );
      expect(controller.isFileDirty(thconfigCanonical), isTrue);

      final THTextFileSaveResult save = await controller.saveTextProjectFile(
        canonicalPath: thconfigCanonical,
        requestedRevision: revision,
        expectedProjectEpoch: controller.projectEpoch,
        expectedRootPath: controller.rootConfigPath,
      );
      expect(save.status, THTextFileSaveStatus.reparseFailed);
    });
  });
}
