// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
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

  final List<Directory> tempDirs = <Directory>[];

  String canonical(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  Directory fixture(String name) {
    final Directory dir = THProjectControllerTestAux.copyFixtureToTemp(name);
    tempDirs.add(dir);

    return dir;
  }

  setUp(() {
    MPLocator().appLocalizations = AppLocalizationsEn();
  });

  tearDown(() {
    for (final Directory dir in tempDirs) {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    }
    tempDirs.clear();
  });

  group('epoch advancement', () {
    test('open, explicit reload, and close each advance the epoch by one', () async {
      final THProjectController controller = THProjectController();
      final String thconfig = p.join(fixture('multiple-sources').path, 'thconfig');

      final int start = controller.projectEpoch;

      await controller.openProject(thconfig);
      expect(controller.projectEpoch, start + 1);

      await controller.reloadProject();
      expect(controller.projectEpoch, start + 2);

      controller.closeProject();
      expect(controller.projectEpoch, start + 3);
    });

    test('reloadProject with no project loaded is a no-op for the epoch', () async {
      final THProjectController controller = THProjectController();
      final int start = controller.projectEpoch;

      await controller.reloadProject();

      expect(controller.projectEpoch, start);
    });

    test('a failed open still advances the epoch exactly once', () async {
      final fake = FakeProjectOperations()..loadError = StateError('nope');
      final THProjectController controller = THProjectController(
        operations: fake.build(),
      );
      final int start = controller.projectEpoch;

      await controller.openProject(
        p.join(fixture('multiple-sources').path, 'thconfig'),
      );

      expect(controller.projectEpoch, start + 1);
      expect(controller.projectRootNode, isNull);
    });
  });

  group('stale async completion isolation', () {
    test(
      'a load held across a close cannot mutate the replacement project',
      () async {
        final fake = FakeProjectOperations();
        final gate = MPAsyncGate();
        fake.loadGate = gate;

        final THProjectController controller = THProjectController(
          operations: fake.build(),
        );
        final String thconfigA =
            p.join(fixture('multiple-sources').path, 'thconfig');

        final Future<void> openA = controller.openProject(thconfigA);
        await gate.started;

        // Project A's load is suspended mid-flight. Close it.
        controller.closeProject();
        expect(controller.rootConfigPath, isEmpty);

        gate.release();
        await openA;

        // A's stale load result must not have populated the closed project.
        expect(controller.projectRootNode, isNull);
        expect(controller.rootConfigPath, isEmpty);
        expect(controller.isParsing, isFalse);
      },
    );

    test(
      'a full reparse held across a close does not touch the closed project',
      () async {
        final fake = FakeProjectOperations();
        final THProjectController controller = THProjectController(
          operations: fake.build(),
        );
        final String thconfig =
            p.join(fixture('multiple-sources').path, 'thconfig');
        await controller.openProject(thconfig);

        final String rootCanonical = canonical(thconfig);
        final int revision = controller.registerTextContentChange(
          canonicalPath: rootCanonical,
          content: 'encoding UTF-8\nsource cave_one.th\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );

        final gate = MPAsyncGate();
        fake.loadGate = gate;

        final Future<void> flush = controller.flushPendingReparse(
          canonicalPath: rootCanonical,
          expectedRevision: revision,
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );

        await gate.started;
        controller.closeProject();
        gate.release();
        await flush;

        expect(controller.projectRootNode, isNull);
        expect(controller.dirtyFilePaths, isEmpty);
        expect(controller.isParsing, isFalse);
      },
    );
  });

  group('single-project editor isolation', () {
    test(
      'reopening the same root produces a controller a stale editor cannot act on',
      () async {
        final THProjectController controller = THProjectController();
        final String thconfig =
            p.join(fixture('multiple-sources').path, 'thconfig');
        final String caveOne =
            canonical(p.join(tempDirs.first.path, 'cave_one.th'));

        await controller.openProject(thconfig);

        final THTextEditorController staleEditor = THTextEditorController(
          projectController: controller,
        );
        addTearDown(staleEditor.dispose);
        await staleEditor.loadFile(caveOne);
        expect(staleEditor.isProjectBound, isTrue);
        expect(staleEditor.matchesCurrentProject(), isTrue);

        // Re-open the same root: a brand-new epoch.
        await controller.openProject(thconfig);

        expect(staleEditor.matchesCurrentProject(), isFalse);

        // The stale editor cannot register content against the new project.
        staleEditor.setContent('survey stale_write\nendsurvey\n');
        expect(staleEditor.lastOperationRejectedByProjectChange, isTrue);
        expect(controller.isFileDirty(caveOne), isFalse);
      },
    );

    test('there is only ever one root/tree through replacement', () async {
      final THProjectController controller = THProjectController();
      final String thconfigA =
          p.join(fixture('multiple-sources').path, 'thconfig');
      final String thconfigB = p.join(fixture('two-level').path, 'thconfig');

      await controller.openProject(thconfigA);
      final Object treeA = controller.projectRootNode!;

      await controller.openProject(thconfigB);
      final Object treeB = controller.projectRootNode!;

      expect(identical(treeA, treeB), isFalse);
      expect(controller.rootConfigPath, canonical(thconfigB));
    });
  });
}
