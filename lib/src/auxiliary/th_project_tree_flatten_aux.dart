// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_project/th_project_node.dart';

/// One visible project-tree row produced by [flattenVisibleNodes].
class THProjectTreeVisibleNode {
  final THProjectNode node;

  final int depth;

  const THProjectTreeVisibleNode({
    required this.node,
    required this.depth,
  });
}

/// Flattens a project tree into the visible rows for [THProjectTreeWidget].
///
/// The walk is depth-first. Without filtering it honors [isExpanded]. With an
/// active filter it shows only nodes whose label matches [matchesFilter] or
/// that have a matching descendant, auto-expanding ancestors without changing
/// the caller's expansion set.
List<THProjectTreeVisibleNode> flattenVisibleNodes({
  required THProjectNode root,
  required bool Function(THProjectNode node) isExpanded,
  required bool Function(THProjectNode node) matchesFilter,
  bool filterActive = false,
}) {
  if (!filterActive) {
    return _flattenWithoutFilter(
      root: root,
      isExpanded: isExpanded,
    );
  }

  final Map<THProjectNode, bool> subtreeMatches = _collectSubtreeMatches(
    root,
    matchesFilter,
  );
  final List<THProjectTreeVisibleNode> visibleNodes =
      <THProjectTreeVisibleNode>[];

  void visit(THProjectNode node, int depth) {
    if (subtreeMatches[node] != true) {
      return;
    }

    visibleNodes.add(
      THProjectTreeVisibleNode(node: node, depth: depth),
    );

    for (final THProjectNode child in node.children) {
      visit(child, depth + 1);
    }
  }

  visit(root, 0);

  return visibleNodes;
}

List<THProjectTreeVisibleNode> _flattenWithoutFilter({
  required THProjectNode root,
  required bool Function(THProjectNode node) isExpanded,
}) {
  final List<THProjectTreeVisibleNode> visibleNodes =
      <THProjectTreeVisibleNode>[];

  void visit(THProjectNode node, int depth) {
    visibleNodes.add(THProjectTreeVisibleNode(node: node, depth: depth));

    if (!isExpanded(node)) {
      return;
    }

    for (final THProjectNode child in node.children) {
      visit(child, depth + 1);
    }
  }

  visit(root, 0);

  return visibleNodes;
}

Map<THProjectNode, bool> _collectSubtreeMatches(
  THProjectNode root,
  bool Function(THProjectNode node) matchesFilter,
) {
  final Map<THProjectNode, bool> result = <THProjectNode, bool>{};

  bool visit(THProjectNode node) {
    bool hasMatch = matchesFilter(node);

    for (final THProjectNode child in node.children) {
      if (visit(child)) {
        hasMatch = true;
      }
    }

    result[node] = hasMatch;

    return hasMatch;
  }

  visit(root);

  return result;
}
