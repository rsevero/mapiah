// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_missing_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_survey_node.dart';
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

  List<T> findAll<T extends THProjectNode>(THProjectNode root) {
    final List<T> result = <T>[];
    final Set<THProjectNode> visited = Set<THProjectNode>.identity();

    void visit(THProjectNode current) {
      if (!visited.add(current)) {
        return;
      }
      if (current is T) {
        result.add(current);
      }
      for (final THProjectNode child in current.children) {
        visit(child);
      }
    }

    visit(root);

    return result;
  }

  /// Builds a 3-level project (thconfig -> outer.th -> inner_a.th/inner_b.th)
  /// in a fresh temp directory, so tests can edit the *non-root* `outer.th`
  /// and observe splicing without needing to save to disk first (editing the
  /// project root always falls back to a full, disk-reading reload).
  Directory buildThreeLevelProject() {
    final Directory dir = Directory.systemTemp.createTempSync(
      'mapiah_th_project_controller_test_',
    );

    File(
      p.join(dir.path, 'thconfig'),
    ).writeAsStringSync('encoding UTF-8\nsource outer.th\n');
    File(p.join(dir.path, 'outer.th')).writeAsStringSync(
      'input inner_a.th\ninput inner_b.th\n',
    );
    File(
      p.join(dir.path, 'inner_a.th'),
    ).writeAsStringSync('survey a\nendsurvey\n');
    File(
      p.join(dir.path, 'inner_b.th'),
    ).writeAsStringSync('survey b\nendsurvey\n');

    return dir;
  }

  tearDown(() {
    controller.closeProject();
    final Directory? dir = tempDir;
    if ((dir != null) && dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
    tempDir = null;
  });

  group('THProjectController incremental re-parse', () {
    test(
      'unchanged re-parse preserves untouched include subtree identity',
      () async {
        tempDir = buildThreeLevelProject();
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String outerCanonical = canonicalPath(
          p.join(tempDir!.path, 'outer.th'),
        );

        await controller.openProject(thconfigPath);

        final THDataFileNode originalOuter =
            controller.nodeByCanonicalPath(outerCanonical)! as THDataFileNode;
        final THDataFileNode originalInnerB = originalOuter.children
            .whereType<THDataFileNode>()
            .firstWhere(
              (THDataFileNode node) => node.absolutePath.endsWith(
                'inner_b.th',
              ),
            );
        final String originalContent =
            controller.fileContentsCache[outerCanonical]!;

        await controller.reparseFile(
          filePath: outerCanonical,
          updatedContent: originalContent,
        );
        await waitForDebounce();

        final THDataFileNode newOuter =
            controller.nodeByCanonicalPath(outerCanonical)! as THDataFileNode;
        final THDataFileNode newInnerB = newOuter.children
            .whereType<THDataFileNode>()
            .firstWhere(
              (THDataFileNode node) => node.absolutePath.endsWith(
                'inner_b.th',
              ),
            );

        expect(identical(newOuter, originalOuter), isFalse);
        expect(identical(newInnerB, originalInnerB), isTrue);
      },
    );

    test(
      'adding an include attaches a new child and updates reverse dependencies',
      () async {
        tempDir = buildThreeLevelProject();
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String outerCanonical = canonicalPath(
          p.join(tempDir!.path, 'outer.th'),
        );
        File(
          p.join(tempDir!.path, 'inner_c.th'),
        ).writeAsStringSync('survey c\nendsurvey\n');

        await controller.openProject(thconfigPath);

        await controller.reparseFile(
          filePath: outerCanonical,
          updatedContent:
              'input inner_a.th\ninput inner_b.th\ninput inner_c.th\n',
        );
        await waitForDebounce();

        final String innerCCanonical = canonicalPath(
          p.join(tempDir!.path, 'inner_c.th'),
        );

        expect(controller.nodeByCanonicalPath(innerCCanonical), isNotNull);
        expect(
          controller.dependenciesOf(outerCanonical),
          contains(innerCCanonical),
        );
        expect(
          controller.dependentsOf(innerCCanonical),
          contains(outerCanonical),
        );
      },
    );

    test(
      'removing an include detaches the child and its index entries',
      () async {
        tempDir = buildThreeLevelProject();
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String outerCanonical = canonicalPath(
          p.join(tempDir!.path, 'outer.th'),
        );
        final String innerBCanonical = canonicalPath(
          p.join(tempDir!.path, 'inner_b.th'),
        );

        await controller.openProject(thconfigPath);
        expect(controller.nodeByCanonicalPath(innerBCanonical), isNotNull);

        await controller.reparseFile(
          filePath: outerCanonical,
          updatedContent: 'input inner_a.th\n',
        );
        await waitForDebounce();

        expect(controller.nodeByCanonicalPath(innerBCanonical), isNull);
        expect(controller.dependentsOf(innerBCanonical), isEmpty);
        expect(
          controller.dependenciesOf(outerCanonical),
          isNot(contains(innerBCanonical)),
        );
      },
    );

    test(
      'renaming a nested survey propagates fullNamespace to descendant surveys',
      () async {
        tempDir = Directory.systemTemp.createTempSync(
          'mapiah_th_project_controller_namespace_test_',
        );
        File(
          p.join(tempDir!.path, 'thconfig'),
        ).writeAsStringSync('encoding UTF-8\nsource outer.th\n');
        File(p.join(tempDir!.path, 'outer.th')).writeAsStringSync(
          'survey cave\n  survey passage\n  endsurvey\nendsurvey\n',
        );

        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        await controller.openProject(thconfigPath);

        final String outerCanonical = canonicalPath(
          p.join(tempDir!.path, 'outer.th'),
        );

        await controller.reparseFile(
          filePath: outerCanonical,
          updatedContent:
              'survey cave\n  survey gallery\n  endsurvey\nendsurvey\n',
        );
        await waitForDebounce();

        final List<THSurveyNode> surveyNodes = findAll<THSurveyNode>(
          controller.projectRootNode!,
        );
        final THSurveyNode innerSurvey = surveyNodes.firstWhere(
          (THSurveyNode node) => node.survey.surveyId == 'gallery',
        );

        expect(innerSurvey.fullNamespace, 'gallery.cave');
      },
    );

    test(
      'an added missing include creates a diagnostic without aborting the branch',
      () async {
        tempDir = buildThreeLevelProject();
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');
        final String outerCanonical = canonicalPath(
          p.join(tempDir!.path, 'outer.th'),
        );

        await controller.openProject(thconfigPath);

        await controller.reparseFile(
          filePath: outerCanonical,
          updatedContent:
              'input inner_a.th\ninput inner_b.th\ninput ghost.th\n',
        );
        await waitForDebounce();

        final List<THMissingFileNode> missingNodes = findAll<
          THMissingFileNode
        >(controller.projectRootNode!);

        expect(
          missingNodes.any(
            (THMissingFileNode node) => node.requestedPath == 'ghost.th',
          ),
          isTrue,
        );
        expect(controller.projectErrors, isNotEmpty);

        final String innerACanonical = canonicalPath(
          p.join(tempDir!.path, 'inner_a.th'),
        );
        expect(controller.nodeByCanonicalPath(innerACanonical), isNotNull);
      },
    );

    test(
      'editing the project root file falls back to a full, disk-reading reload',
      () async {
        tempDir = THProjectControllerTestAux.copyFixtureToTemp(
          'multiple-sources',
        );
        final String thconfigPath = p.join(tempDir!.path, 'thconfig');

        await controller.openProject(thconfigPath);

        await controller.reparseFile(
          filePath: thconfigPath,
          updatedContent: 'encoding UTF-8\nsource cave_one.th\n',
        );
        expect(controller.dirtyFilePaths, isNotEmpty);

        await waitForDebounce();

        // A full reload's _applyLoadResult always resets dirtyFilePaths and
        // re-reads the root from disk, which was never actually written by
        // this test, so the tree still reflects both original sources.
        expect(controller.dirtyFilePaths, isEmpty);
        expect(
          (controller.projectRootNode! as THConfigFileNode).children,
          hasLength(2),
        );
      },
    );

    test('rapid successive edits are coalesced by the debounce timer', () async {
      tempDir = buildThreeLevelProject();
      final String thconfigPath = p.join(tempDir!.path, 'thconfig');
      final String innerACanonical = canonicalPath(
        p.join(tempDir!.path, 'inner_a.th'),
      );

      await controller.openProject(thconfigPath);

      await controller.reparseFile(
        filePath: innerACanonical,
        updatedContent: 'survey alpha\nendsurvey\n',
      );
      await controller.reparseFile(
        filePath: innerACanonical,
        updatedContent: 'survey beta\nendsurvey\n',
      );
      await controller.reparseFile(
        filePath: innerACanonical,
        updatedContent: 'survey gamma\nendsurvey\n',
      );
      await waitForDebounce();

      final List<THSurveyNode> surveyNodes = findAll<THSurveyNode>(
        controller.projectRootNode!,
      );

      expect(
        surveyNodes.map((THSurveyNode node) => node.survey.surveyId),
        contains('gamma'),
      );
      expect(
        surveyNodes.map((THSurveyNode node) => node.survey.surveyId),
        isNot(anyOf(contains('alpha'), contains('beta'))),
      );
    });

    test('preserves a linked .th2 leaf across an unrelated re-parse', () async {
      tempDir = THProjectControllerTestAux.copyFixtureToTemp('two-level');
      final String thconfigPath = p.join(tempDir!.path, 'thconfig');

      await controller.openProject(thconfigPath);

      final String caveCanonical = canonicalPath(
        p.join(tempDir!.path, 'cave.th'),
      );
      final THDataFileNode originalCave =
          controller.nodeByCanonicalPath(caveCanonical)! as THDataFileNode;
      final TH2FileNode originalTH2 = findAll<TH2FileNode>(
        originalCave,
      ).single;
      final String originalContent =
          controller.fileContentsCache[caveCanonical]!;

      await controller.reparseFile(
        filePath: caveCanonical,
        updatedContent: originalContent,
      );
      await waitForDebounce();

      final THDataFileNode newCave =
          controller.nodeByCanonicalPath(caveCanonical)! as THDataFileNode;
      final TH2FileNode newTH2 = findAll<TH2FileNode>(newCave).single;

      expect(identical(newTH2, originalTH2), isTrue);
    });
  });
}
