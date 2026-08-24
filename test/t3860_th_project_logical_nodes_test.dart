// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_centreline_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_map_node.dart';
import 'package:mapiah/src/elements/th_project/th_scrap_node.dart';
import 'package:mapiah/src/elements/th_project/th_survey_node.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:path/path.dart' as p;

void main() {
  group('THProject logical nodes', () {
    late THProjectLoadResult result;

    setUp(() {
      final String fixturePath = p.join(
        Directory.current.path,
        'test',
        'auxiliary',
        'th_project',
        'mixed-logical',
        'cave.th',
      );

      result = THProjectParser.loadProject(fixturePath);
    });

    test('creates a top-level centreline node', () {
      final THDataFileNode dataNode = result.rootNode as THDataFileNode;

      expect(dataNode.children.whereType<THCentrelineNode>(), hasLength(1));
      expect(
        dataNode.children.whereType<THCentrelineNode>().single.centreline.shots,
        hasLength(1),
      );
    });

    test('creates nested map children from map references', () {
      final THDataFileNode dataNode = result.rootNode as THDataFileNode;
      final THSurveyNode surveyNode =
          dataNode.children.whereType<THSurveyNode>().single;
      final List<THMapNode> mapNodes =
          surveyNode.children.whereType<THMapNode>().toList();

      expect(mapNodes.map((THMapNode node) => node.map.mapId), [
        'overview',
        'plan_map',
      ]);

      final THMapNode overviewNode = mapNodes.first;
      expect(overviewNode.children, hasLength(1));
      expect(
        (overviewNode.children.single as THMapNode).map.mapId,
        'plan_map',
      );
    });

    test('creates an inline scrap node from a .th file', () {
      final THDataFileNode dataNode = result.rootNode as THDataFileNode;
      final THSurveyNode surveyNode =
          dataNode.children.whereType<THSurveyNode>().single;
      final THScrapNode scrapNode =
          surveyNode.children.whereType<THScrapNode>().single;

      expect(scrapNode.scrapId, 'inline_scrap');
      expect(scrapNode.isFromTH2File, isFalse);
    });

    test('links .th2 inputs as leaves without synthesizing scraps', () {
      final THDataFileNode dataNode = result.rootNode as THDataFileNode;
      final THSurveyNode surveyNode =
          dataNode.children.whereType<THSurveyNode>().single;

      expect(surveyNode.children.whereType<TH2FileNode>(), hasLength(1));
      expect(
        surveyNode.children.whereType<THScrapNode>().single.isFromTH2File,
        isFalse,
      );
    });

    test('preserves mixed nesting shape from source order', () {
      final THDataFileNode dataNode = result.rootNode as THDataFileNode;

      expect(dataNode.children, hasLength(2));
      expect(dataNode.children.first, isA<THCentrelineNode>());
      expect(dataNode.children.last, isA<THSurveyNode>());

      final THSurveyNode surveyNode = dataNode.children.last as THSurveyNode;
      expect(surveyNode.children, hasLength(4));
      expect(surveyNode.children[0], isA<TH2FileNode>());
      expect(surveyNode.children[1], isA<THMapNode>());
      expect(surveyNode.children[2], isA<THMapNode>());
      expect(surveyNode.children[3], isA<THScrapNode>());
    });
  });
}
