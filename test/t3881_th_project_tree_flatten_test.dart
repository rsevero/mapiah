// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_flatten_aux.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';

class _FakeNode extends THProjectNode {
  _FakeNode({
    required super.id,
    required super.label,
    super.lineNumber = 0,
  }) : super(sourceFilePath: '/tmp/fake.th');
}

void main() {
  late _FakeNode root;
  late _FakeNode childA;
  late _FakeNode childB;
  late _FakeNode grandchild;

  setUp(() {
    root = _FakeNode(id: 'root', label: 'root');
    childA = _FakeNode(id: 'a', label: 'alpha');
    childB = _FakeNode(id: 'b', label: 'beta');
    grandchild = _FakeNode(id: 'c', label: 'charlie');

    root.addChild(childA);
    root.addChild(childB);
    childA.addChild(grandchild);
  });

  List<String> labelsOf(List<THProjectTreeVisibleRow> rows) {
    return rows
        .map((THProjectTreeVisibleRow row) => (row as THProjectTreeNodeRow))
        .map((THProjectTreeNodeRow row) => row.node.label)
        .toList();
  }

  List<int> depthsOf(List<THProjectTreeVisibleRow> rows) {
    return rows.map((THProjectTreeVisibleRow row) => row.depth).toList();
  }

  test('flattens depth-first and honors expansion without filter', () {
    final List<THProjectTreeVisibleRow> result = flattenVisibleNodes(
      root: root,
      isExpanded: (THProjectNode node) =>
          node.id == 'root' || node.id == 'a',
      matchesFilter: (_) => false,
    );

    expect(labelsOf(result), <String>['root', 'alpha', 'charlie', 'beta']);
    expect(depthsOf(result), <int>[0, 1, 2, 1]);
  });

  test('filter shows matching leaves and auto-expands ancestors', () {
    final Set<String> expanded = <String>{};
    final List<THProjectTreeVisibleRow> result = flattenVisibleNodes(
      root: root,
      isExpanded: (THProjectNode node) => expanded.contains(node.id),
      matchesFilter: (THProjectNode node) => node.label == 'charlie',
      filterActive: true,
    );

    expect(labelsOf(result), <String>['root', 'alpha', 'charlie']);
    expect(depthsOf(result), <int>[0, 1, 2]);
    expect(expanded, isEmpty, reason: 'filter must not mutate expansion set');
  });

  test('filter matching an ancestor hides non-matching descendants', () {
    final List<THProjectTreeVisibleRow> result = flattenVisibleNodes(
      root: root,
      isExpanded: (_) => false,
      matchesFilter: (THProjectNode node) => node.label == 'alpha',
      filterActive: true,
    );

    expect(labelsOf(result), <String>['root', 'alpha']);
  });

  test('clearing filter restores the prior manual expansion state', () {
    final Set<String> expanded = <String>{'root', 'a'};

    final List<THProjectTreeVisibleRow> filtered = flattenVisibleNodes(
      root: root,
      isExpanded: (THProjectNode node) => expanded.contains(node.id),
      matchesFilter: (THProjectNode node) => node.label == 'charlie',
      filterActive: true,
    );

    expect(labelsOf(filtered), <String>['root', 'alpha', 'charlie']);

    final List<THProjectTreeVisibleRow> unfiltered = flattenVisibleNodes(
      root: root,
      isExpanded: (THProjectNode node) => expanded.contains(node.id),
      matchesFilter: (_) => false,
      filterActive: false,
    );

    expect(labelsOf(unfiltered), <String>['root', 'alpha', 'charlie', 'beta']);
    expect(expanded, <String>{'root', 'a'});
  });

  test('stale expansion ids after a reparse are inert', () {
    final Set<String> expanded = <String>{'stale-id'};
    final List<THProjectTreeVisibleRow> result = flattenVisibleNodes(
      root: root,
      isExpanded: (THProjectNode node) => expanded.contains(node.id),
      matchesFilter: (_) => false,
    );

    expect(labelsOf(result), <String>['root']);
  });
}
