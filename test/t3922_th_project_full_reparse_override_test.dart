// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_project_reparse_flush_result.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
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

  group('THProjectParser content overrides', () {
    test(
      'an empty override map behaves as today and still returns snapshots',
      () {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfig = p.join(tempDir!.path, 'thconfig');

        final THProjectLoadResult withoutOverrides =
            THProjectParser.loadProject(thconfig);
        final THProjectLoadResult withEmptyOverrides = THProjectParser.loadProject(
          thconfig,
          contentOverrides: const <String, THProjectContentOverride>{},
        );

        expect(
          withEmptyOverrides.rootNode.children.length,
          withoutOverrides.rootNode.children.length,
        );

        final String caveOne = canonical(p.join(tempDir!.path, 'cave_one.th'));
        final THProjectParsedContentSnapshot? snapshot =
            withEmptyOverrides.contentSnapshotsByCanonicalPath[caveOne];

        expect(snapshot, isNotNull);
        expect(snapshot!.provenance, THProjectContentProvenance.disk);
        expect(snapshot.overrideRevision, isNull);
        expect(snapshot.content, 'survey one\nendsurvey\n');
      },
    );

    test(
      'a revision-bearing override builds the node from pending content',
      () {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfig = p.join(tempDir!.path, 'thconfig');
        final String caveOne = canonical(p.join(tempDir!.path, 'cave_one.th'));

        final THProjectLoadResult result = THProjectParser.loadProject(
          thconfig,
          contentOverrides: <String, THProjectContentOverride>{
            caveOne: const THProjectContentOverride(
              content: 'survey overridden\nendsurvey\n',
              revision: 7,
            ),
          },
        );

        final THProjectParsedContentSnapshot snapshot =
            result.contentSnapshotsByCanonicalPath[caveOne]!;

        expect(snapshot.provenance, THProjectContentProvenance.override);
        expect(snapshot.overrideRevision, 7);
        expect(snapshot.content, 'survey overridden\nendsurvey\n');

        // A file with no override still reads from disk.
        final String caveTwo = canonical(p.join(tempDir!.path, 'cave_two.th'));
        expect(
          result.contentSnapshotsByCanonicalPath[caveTwo]!.provenance,
          THProjectContentProvenance.disk,
        );
      },
    );
  });

  group('dirty-preserving full reparse via the controller', () {
    test(
      'a full reparse keeps another file\'s unsaved content and revision',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfig = p.join(tempDir!.path, 'thconfig');
        final String thconfigCanonical = canonical(thconfig);
        final String caveTwo = canonical(p.join(tempDir!.path, 'cave_two.th'));

        final THProjectController controller = THProjectController();
        await controller.openProject(thconfig);

        // An unsaved edit to a non-root file.
        final int caveTwoRevision = controller.registerTextContentChange(
          canonicalPath: caveTwo,
          content: 'survey cave_two_unsaved\nendsurvey\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );

        // A root edit forces the dirty-preserving full reparse.
        final int rootRevision = controller.registerTextContentChange(
          canonicalPath: thconfigCanonical,
          content: 'encoding UTF-8\nsource cave_one.th\nsource cave_two.th\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );

        final THProjectReparseFlushResult flush = await controller
            .flushPendingReparse(
              canonicalPath: thconfigCanonical,
              expectedRevision: rootRevision,
              expectedProjectEpoch: controller.projectEpoch,
              expectedRootPath: controller.rootConfigPath,
            );

        expect(flush.status, THProjectReparseFlushStatus.reparsed);
        // cave_two's unsaved content and revision survived the rebuild.
        expect(
          controller.fileContentsCache[caveTwo],
          'survey cave_two_unsaved\nendsurvey\n',
        );
        expect(controller.isFileDirty(caveTwo), isTrue);
        expect(
          controller
              .textContentSnapshot(caveTwo)
              .currentRevision,
          caveTwoRevision,
        );
      },
    );

    test(
      'a failed full reparse leaves the prior tree and all dirty state intact',
      () async {
        final fake = FakeProjectOperations();
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfig = p.join(tempDir!.path, 'thconfig');
        final String thconfigCanonical = canonical(thconfig);

        final THProjectController controller = THProjectController(
          operations: fake.build(),
        );
        await controller.openProject(thconfig);
        final Object treeBefore = controller.projectRootNode!;

        final int revision = controller.registerTextContentChange(
          canonicalPath: thconfigCanonical,
          content: 'encoding UTF-8\nsource cave_one.th\n',
          expectedProjectEpoch: controller.projectEpoch,
          expectedRootPath: controller.rootConfigPath,
        );

        fake.loadError = StateError('kaboom');

        final THProjectReparseFlushResult flush = await controller
            .flushPendingReparse(
              canonicalPath: thconfigCanonical,
              expectedRevision: revision,
              expectedProjectEpoch: controller.projectEpoch,
              expectedRootPath: controller.rootConfigPath,
            );

        expect(flush.status, THProjectReparseFlushStatus.failed);
        expect(identical(controller.projectRootNode, treeBefore), isTrue);
        expect(controller.isFileDirty(thconfigCanonical), isTrue);
      },
    );
  });
}
