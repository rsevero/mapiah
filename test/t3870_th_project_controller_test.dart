// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final THProjectController controller = MPLocator().thProjectController;

  final String fixtureRoot = p.join(
    Directory.current.path,
    'test',
    'auxiliary',
    'th_project',
  );

  String fixturePath(String relativePath) => p.join(fixtureRoot, relativePath);

  String canonicalPath(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  tearDown(() {
    controller.closeProject();
  });

  group('THProjectController lifecycle', () {
    test('openProject builds the full tree and both dependency maps', () async {
      final String thconfigPath = fixturePath('multiple-sources/thconfig');

      await controller.openProject(thconfigPath);

      expect(controller.isParsing, isFalse);
      expect(controller.rootConfigPath, canonicalPath(thconfigPath));
      expect(controller.projectRootNode, isA<THConfigFileNode>());
      expect(controller.projectErrors, isEmpty);

      final String caveOneCanonical = canonicalPath(
        fixturePath('multiple-sources/cave_one.th'),
      );
      final String caveTwoCanonical = canonicalPath(
        fixturePath('multiple-sources/cave_two.th'),
      );

      expect(controller.nodeByCanonicalPath(caveOneCanonical), isNotNull);
      expect(controller.nodeByCanonicalPath(caveTwoCanonical), isNotNull);
      expect(
        controller.dependenciesOf(controller.rootConfigPath),
        containsAll(<String>[caveOneCanonical, caveTwoCanonical]),
      );
      expect(
        controller.dependentsOf(caveOneCanonical),
        contains(controller.rootConfigPath),
      );
      expect(
        controller.fileContentsCache[controller.rootConfigPath],
        isNotNull,
      );
      expect(controller.fileContentsCache[caveOneCanonical], isNotNull);
    });

    test('reload idempotence: two reloads do not duplicate file nodes', () async {
      final String thconfigPath = fixturePath('multiple-sources/thconfig');

      await controller.openProject(thconfigPath);

      final int childCountAfterOpen =
          (controller.projectRootNode! as THConfigFileNode).children.length;

      await controller.reloadProject();
      await controller.reloadProject();

      final int childCountAfterReloads =
          (controller.projectRootNode! as THConfigFileNode).children.length;

      expect(childCountAfterReloads, childCountAfterOpen);
      expect(childCountAfterOpen, 2);
    });

    test('selectNode only mutates activeSelectedNodeId', () async {
      final String thconfigPath = fixturePath('multiple-sources/thconfig');

      await controller.openProject(thconfigPath);
      expect(controller.activeSelectedNodeId, isNull);

      final String rootId = controller.projectRootNode!.id;
      controller.selectNode(rootId);

      expect(controller.activeSelectedNodeId, rootId);
    });

    test('hasUnsavedChanges reflects dirtyFilePaths', () async {
      final String thconfigPath = fixturePath('multiple-sources/thconfig');

      await controller.openProject(thconfigPath);
      expect(controller.hasUnsavedChanges, isFalse);

      final String caveOneCanonical = canonicalPath(
        fixturePath('multiple-sources/cave_one.th'),
      );

      await controller.reparseFile(
        filePath: caveOneCanonical,
        updatedContent: 'survey one\nendsurvey\n',
      );

      expect(controller.hasUnsavedChanges, isTrue);
      expect(controller.isFileDirty(caveOneCanonical), isTrue);
    });

    test('closeProject clears all observable and private state', () async {
      final String thconfigPath = fixturePath('multiple-sources/thconfig');

      await controller.openProject(thconfigPath);
      controller.selectNode(controller.projectRootNode!.id);
      controller.closeProject();

      expect(controller.rootConfigPath, isEmpty);
      expect(controller.projectRootNode, isNull);
      expect(controller.isParsing, isFalse);
      expect(controller.activeSelectedNodeId, isNull);
      expect(controller.projectErrors, isEmpty);
      expect(controller.fileContentsCache, isEmpty);
      expect(controller.dirtyFilePaths, isEmpty);
      expect(
        controller.nodeByCanonicalPath(
          canonicalPath(fixturePath('multiple-sources/cave_one.th')),
        ),
        isNull,
      );
      expect(controller.dependenciesOf('anything'), isEmpty);
    });

    test('opens a project rooted at a .th file when there is no thconfig', () async {
      final String rootPath = fixturePath('nested-surveys/cave.th');

      await controller.openProject(rootPath);

      expect(controller.projectRootNode, isA<THDataFileNode>());
      expect(controller.rootConfigPath, canonicalPath(rootPath));
    });

    test(
      'openProject can force an extensionless selected file to config',
      () async {
        final Directory tempDirectory = await Directory.systemTemp.createTemp(
          'mapiah_phase4_force_config_',
        );
        addTearDown(() => tempDirectory.delete(recursive: true));

        final String configPath = p.join(
          tempDirectory.path,
          'therion_uis_showcase',
        );
        final String dataPath = p.join(tempDirectory.path, 'cave.th');

        File(configPath).writeAsStringSync(
          'encoding UTF-8\nsource cave.th\n',
        );
        File(dataPath).writeAsStringSync(
          'encoding UTF-8\nsurvey cave\nendsurvey\n',
        );

        await controller.openProject(
          configPath,
          forceConfigShape: true,
        );

        expect(controller.projectRootNode, isA<THConfigFileNode>());
        expect(controller.projectErrors, isEmpty);

        final THConfigFileNode root =
            controller.projectRootNode! as THConfigFileNode;

        expect(root.children, hasLength(1));
        expect(root.children.single, isA<THDataFileNode>());
        expect(
          (root.children.single as THDataFileNode).absolutePath,
          canonicalPath(dataPath),
        );
      },
    );
  });
}
