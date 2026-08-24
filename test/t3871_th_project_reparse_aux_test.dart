// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/controllers/th_project_reparse_aux.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

void main() {
  final String fixtureRoot = p.join(
    Directory.current.path,
    'test',
    'auxiliary',
    'th_project',
  );

  String fixturePath(String relativePath) => p.join(fixtureRoot, relativePath);

  String canonicalPath(String path) =>
      THProjectPathResolver.canonicalize(p.absolute(path));

  group('shouldFullReloadForReparse', () {
    test('no project root loaded', () {
      expect(
        shouldFullReloadForReparse(
          hasProjectRoot: false,
          isRootFile: false,
          isKnownFile: true,
          typeChanged: false,
        ),
        isTrue,
      );
    });

    test('editing the project root file', () {
      expect(
        shouldFullReloadForReparse(
          hasProjectRoot: true,
          isRootFile: true,
          isKnownFile: true,
          typeChanged: false,
        ),
        isTrue,
      );
    });

    test('editing a file not present in the tree', () {
      expect(
        shouldFullReloadForReparse(
          hasProjectRoot: true,
          isRootFile: false,
          isKnownFile: false,
          typeChanged: false,
        ),
        isTrue,
      );
    });

    test('local parse changed the file type', () {
      expect(
        shouldFullReloadForReparse(
          hasProjectRoot: true,
          isRootFile: false,
          isKnownFile: true,
          typeChanged: true,
        ),
        isTrue,
      );
    });

    test('known, non-root, unchanged-type file allows a local splice', () {
      expect(
        shouldFullReloadForReparse(
          hasProjectRoot: true,
          isRootFile: false,
          isKnownFile: true,
          typeChanged: false,
        ),
        isFalse,
      );
    });
  });

  group('collectDescendantFileNodes', () {
    test('collects every file node in a subtree keyed by canonical path', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('multiple-sources/thconfig'),
      );

      final Map<String, THProjectFileNode> nodes = collectDescendantFileNodes(
        result.rootNode,
      );

      expect(nodes.keys, hasLength(3));
      expect(
        nodes.keys,
        containsAll(<String>[
          canonicalPath(fixturePath('multiple-sources/thconfig')),
          canonicalPath(fixturePath('multiple-sources/cave_one.th')),
          canonicalPath(fixturePath('multiple-sources/cave_two.th')),
        ]),
      );
    });
  });

  group('rebuildProjectIndexes', () {
    test('indexes both file nodes and logical nodes by id', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('nested-surveys/cave.th'),
      );

      final Map<String, THProjectFileNode> nodesByCanonicalPath =
          <String, THProjectFileNode>{};
      final Map<String, THProjectNode> nodesById = <String, THProjectNode>{};

      rebuildProjectIndexes(
        root: result.rootNode,
        nodesByCanonicalPath: nodesByCanonicalPath,
        nodesById: nodesById,
      );

      expect(nodesByCanonicalPath, hasLength(2));
      expect(nodesById.length, greaterThan(nodesByCanonicalPath.length));
      expect(nodesById[result.rootNode.id], same(result.rootNode));
    });
  });

  group('rebuildDependencyMaps', () {
    test('derives edges regardless of survey nesting depth', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('nested-surveys/cave.th'),
      );

      final Map<String, Set<String>> fileDependencies = <String, Set<String>>{};
      final Map<String, Set<String>> reverseDependencies =
          <String, Set<String>>{};

      rebuildDependencyMaps(
        root: result.rootNode,
        fileDependencies: fileDependencies,
        reverseDependencies: reverseDependencies,
      );

      final String caveCanonical = canonicalPath(
        fixturePath('nested-surveys/cave.th'),
      );
      final String roomTH2Canonical = canonicalPath(
        fixturePath('nested-surveys/room.th2'),
      );

      expect(fileDependencies[caveCanonical], contains(roomTH2Canonical));
      expect(reverseDependencies[roomTH2Canonical], contains(caveCanonical));
      expect(fileDependencies, equals(result.fileDependencies));
      expect(reverseDependencies, equals(result.reverseDependencies));
    });
  });

  group('collectTreeErrors / looseProjectErrors', () {
    test('collectTreeErrors gathers node-attached errors', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('missing-file/thconfig'),
      );

      final List<THProjectParseError> treeErrors = collectTreeErrors(
        result.rootNode,
      );

      expect(treeErrors, isNotEmpty);
      expect(
        treeErrors.every(result.projectErrors.contains),
        isTrue,
      );
    });

    test('looseProjectErrors recovers cycle warnings attached to no node', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('circular-include/a.th'),
      );

      final List<THProjectParseError> treeErrors = collectTreeErrors(
        result.rootNode,
      );
      final List<THProjectParseError> loose = looseProjectErrors(
        resultProjectErrors: result.projectErrors,
        treeErrors: treeErrors,
      );

      expect(loose, isNotEmpty);
      expect(
        loose.every(
          (THProjectParseError error) =>
              error.message.contains('Cycle detected'),
        ),
        isTrue,
      );
      expect(
        looseProjectErrors(
          resultProjectErrors: treeErrors,
          treeErrors: treeErrors,
        ),
        isEmpty,
      );
    });
  });
}
