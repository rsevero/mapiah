// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_missing_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/elements/th_project/th_survey_node.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:path/path.dart' as p;

void main() {
  group('THProjectParser', () {
    late String fixtureRoot;

    setUp(() {
      fixtureRoot = p.join(
        Directory.current.path,
        'test',
        'auxiliary',
        'th_project',
      );
    });

    String fixturePath(String relativePath) {
      return p.join(fixtureRoot, relativePath);
    }

    String canonicalPath(String path) {
      return THProjectPathResolver.canonicalize(p.absolute(path));
    }

    List<T> nodesOfType<T extends THProjectNode>(THProjectFileNode root) {
      final List<T> result = <T>[];

      void visit(THProjectNode node) {
        for (final dynamic child in node.children) {
          if (child is T) {
            result.add(child);
          }
          if (child is THProjectNode) {
            visit(child);
          }
        }
      }

      visit(root);

      return result;
    }

    test('loads a single-file thconfig project', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('single-config/thconfig'),
      );

      expect(result.rootNode, isA<THConfigFileNode>());
      expect(result.rootNode.children, isEmpty);
      expect(result.projectErrors, isEmpty);
    });

    test('loads a root .th file when there is no thconfig', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('root-th/cave.th'),
      );

      expect(result.rootNode, isA<THDataFileNode>());
      expect(result.projectErrors, isEmpty);
    });

    test('loads a two-level config to data to th2 chain', () {
      final String thconfigPath = fixturePath('two-level/thconfig');
      final String dataPath = fixturePath('two-level/cave.th');
      final String th2Path = fixturePath('two-level/passage.th2');

      final THProjectLoadResult result = THProjectParser.loadProject(
        thconfigPath,
      );

      expect(result.rootNode, isA<THConfigFileNode>());
      expect(result.rootNode.children, hasLength(1));

      final THDataFileNode dataNode =
          result.rootNode.children.single as THDataFileNode;
      expect(dataNode.absolutePath, canonicalPath(dataPath));
      expect(dataNode.relativePathToProjectRoot, 'cave.th');

      final THSurveyNode surveyNode =
          dataNode.children.whereType<THSurveyNode>().single;
      final TH2FileNode th2Node =
          surveyNode.children.whereType<TH2FileNode>().single;
      expect(th2Node.absolutePath, canonicalPath(th2Path));
      expect(th2Node.isLoaded, isTrue);
      expect(result.projectErrors, isEmpty);
    });

    test('computes nested survey namespaces leaf-to-root', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('nested-surveys/cave.th'),
      );

      final List<THSurveyNode> surveyNodes =
          nodesOfType<THSurveyNode>(result.rootNode);

      expect(surveyNodes.map((THSurveyNode node) => node.fullNamespace), [
        'cave',
        'passage.cave',
        'room.passage.cave',
      ]);
    });

    test('loads multiple source files as siblings', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('multiple-sources/thconfig'),
      );

      expect(result.rootNode.children, hasLength(2));
      expect(
        result.rootNode.children.whereType<THDataFileNode>(),
        hasLength(2),
      );
    });

    test('creates a missing-file node and continues loading', () {
      final String thconfigPath = fixturePath('missing-file/thconfig');
      final THProjectLoadResult result = THProjectParser.loadProject(
        thconfigPath,
      );

      final THMissingFileNode missingNode = result.rootNode.children
          .whereType<THMissingFileNode>()
          .single;

      expect(missingNode.requestedPath, 'missing.th');
      expect(missingNode.lineNumber, 2);
      expect(missingNode.hasErrors, isTrue);

      final THProjectParseError missingError = result.projectErrors.singleWhere(
        (THProjectParseError error) =>
            error.severity == THProjectParseErrorSeverity.error,
      );
      expect(missingError.filePath, canonicalPath(thconfigPath));
      expect(missingError.lineNumber, 2);

      expect(
        result.rootNode.children.whereType<THDataFileNode>(),
        hasLength(1),
      );
    });

    test('detects a circular include without infinite recursion', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('circular-include/a.th'),
      );

      final THDataFileNode aNode = result.rootNode as THDataFileNode;
      final THDataFileNode bNode = aNode.children.single as THDataFileNode;

      expect(bNode.children.single, same(aNode));
      expect(
        result.projectErrors.any(
          (THProjectParseError error) =>
              error.severity == THProjectParseErrorSeverity.warning,
        ),
        isTrue,
      );
    });

    test('detects a self-include', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('self-include/self.th'),
      );

      expect(result.rootNode.children.single, same(result.rootNode));
      expect(
        result.projectErrors.any(
          (THProjectParseError error) =>
              error.severity == THProjectParseErrorSeverity.warning,
        ),
        isTrue,
      );
    });

    test('applies default .th extension for extensionless inputs', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('default-extension/cave.th'),
      );

      final THSurveyNode surveyNode = result.rootNode.children
          .whereType<THSurveyNode>()
          .single;
      final List<THProjectFileNode> inputs = surveyNode.children
          .whereType<THProjectFileNode>()
          .toList();

      expect(inputs, hasLength(2));
      expect(inputs.first, isA<THDataFileNode>());
      expect(
        (inputs.first as THDataFileNode).absolutePath,
        canonicalPath(fixturePath('default-extension/passage.th')),
      );
      expect(inputs.last, isA<TH2FileNode>());
    });

    test('diagnoses import targets without creating tree nodes', () {
      final THProjectLoadResult result = THProjectParser.loadProject(
        fixturePath('import-missing/cave.th'),
      );

      expect(
        result.rootNode.children.whereType<THProjectFileNode>(),
        isEmpty,
      );
      expect(result.rootNode.hasErrors, isTrue);
      expect(
        result.projectErrors.any(
          (THProjectParseError error) => error.message.contains('Import file'),
        ),
        isTrue,
      );
    });

    test('builds forward and reverse dependency maps', () {
      final String thconfigPath = fixturePath('two-level/thconfig');
      final String dataPath = fixturePath('two-level/cave.th');
      final String th2Path = fixturePath('two-level/passage.th2');

      final THProjectLoadResult result = THProjectParser.loadProject(
        thconfigPath,
      );

      final String thconfigKey = canonicalPath(thconfigPath);
      final String dataKey = canonicalPath(dataPath);
      final String th2Key = canonicalPath(th2Path);

      expect(result.fileDependencies[thconfigKey], {dataKey});
      expect(result.reverseDependencies[dataKey], {thconfigKey});
      expect(result.fileDependencies[dataKey], contains(th2Key));
      expect(result.fileDependencies.containsKey(th2Key), isFalse);
    });

    test('reads a declared non-UTF-8 encoding', () async {
      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'mapiah_phase2_encoding_',
      );
      addTearDown(() => tempDirectory.delete(recursive: true));

      final String dataPath = p.join(tempDirectory.path, 'cave.th');
      final List<int> bytes = latin1.encode(
        'encoding ISO-8859-1\nsurvey café\nendsurvey\n',
      );
      File(dataPath).writeAsBytesSync(bytes);

      final THProjectLoadResult result = THProjectParser.loadProject(dataPath);

      final THDataFileNode dataNode = result.rootNode as THDataFileNode;
      expect(dataNode.dataFile.surveys.single.surveyId, 'café');
    });
  });
}
