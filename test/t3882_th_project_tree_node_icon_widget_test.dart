// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_centreline_node.dart';
import 'package:mapiah/src/elements/th_project/th_map_node.dart';
import 'package:mapiah/src/elements/th_project/th_missing_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_scrap_node.dart';
import 'package:mapiah/src/elements/th_project/th_survey_node.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:mapiah/src/widgets/th_project_tree_node_icon_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

void main() {
  testWidgets('selects an icon for every supported node runtime type', (
    WidgetTester tester,
  ) async {
    final String mixedLogicalPath = p.join(
      Directory.current.path,
      'test',
      'auxiliary',
      'th_project',
      'mixed-logical',
      'cave.th',
    );
    final String singleConfigPath = p.join(
      Directory.current.path,
      'test',
      'auxiliary',
      'th_project',
      'single-config',
      'thconfig',
    );
    final String missingFilePath = p.join(
      Directory.current.path,
      'test',
      'auxiliary',
      'th_project',
      'missing-file',
      'thconfig',
    );

    final THProjectNode mixedRoot = THProjectParser.loadProject(
      mixedLogicalPath,
    ).rootNode;
    final THProjectNode configRoot = THProjectParser.loadProject(
      singleConfigPath,
    ).rootNode;
    final THProjectNode missingRoot = THProjectParser.loadProject(
      missingFilePath,
    ).rootNode;

    final List<(THProjectNode, IconData)> cases = <(THProjectNode, IconData)>[
      (configRoot, Icons.settings_suggest_outlined),
      (mixedRoot, Icons.description_outlined),
      (
        _firstWhere<TH2FileNode>(mixedRoot),
        Icons.draw_outlined,
      ),
      (
        _firstWhere<THSurveyNode>(mixedRoot),
        Icons.account_balance_outlined,
      ),
      (
        _firstWhere<THCentrelineNode>(mixedRoot),
        Icons.timeline_outlined,
      ),
      (
        _firstWhere<THMapNode>(mixedRoot),
        Icons.layers_outlined,
      ),
      (
        _firstWhere<THScrapNode>(mixedRoot),
        Icons.map_outlined,
      ),
      (
        _firstWhere<THMissingFileNode>(missingRoot),
        Icons.error_outline,
      ),
    ];

    for (final (THProjectNode, IconData) testCase in cases) {
      final THProjectNode node = testCase.$1;
      final IconData expectedIcon = testCase.$2;

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: THProjectTreeNodeIconWidget(node: node),
          ),
        ),
      );

      final Icon icon = tester.widget<Icon>(find.byType(Icon));

      expect(icon.icon, expectedIcon, reason: 'Unexpected icon for $node');

      if (node is THMissingFileNode) {
        final BuildContext context = tester.element(
          find.byType(THProjectTreeNodeIconWidget),
        );

        expect(icon.color, Theme.of(context).colorScheme.error);
      }
    }
  });
}

THProjectNode _firstWhere<T extends THProjectNode>(THProjectNode root) {
  final List<THProjectNode> nodes = <THProjectNode>[];

  void visit(THProjectNode node) {
    nodes.add(node);

    for (final THProjectNode child in node.children) {
      visit(child);
    }
  }

  visit(root);

  return nodes.firstWhere((THProjectNode node) => node is T);
}
