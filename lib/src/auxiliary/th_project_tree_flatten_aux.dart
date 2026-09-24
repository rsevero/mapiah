// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/th_project_tree_visible_row.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';

export 'package:mapiah/src/auxiliary/th_project_tree_visible_row.dart';

/// The rows a `.th2` file contributes below its file row, and, while a filter
/// is active, whether any of its scraps or elements matched.
typedef TH2ElementRowsResult = ({
  List<THProjectTreeVisibleRow> rows,
  bool hasMatch,
});

/// Builds the rows below an expanded (or, while filtering, matching) `.th2`
/// file row. [depth] is the depth of the file row itself.
typedef TH2ElementRowsCallback =
    TH2ElementRowsResult Function(
      TH2FileNode node,
      int depth, {
      required bool filterActive,
    });

/// Flattens a project tree into the visible rows for [THProjectTreeWidget].
///
/// The walk is depth-first. Without filtering it honors [isExpanded]. With an
/// active filter it shows only nodes whose label matches [matchesFilter] or
/// that have a matching descendant, auto-expanding ancestors without changing
/// the caller's expansion set. [th2ElementRowsFor], when given, supplies the
/// element and status rows of `.th2` files; it is called at most once per
/// file per flattening.
List<THProjectTreeVisibleRow> flattenVisibleNodes({
  required THProjectNode root,
  required bool Function(THProjectNode node) isExpanded,
  required bool Function(THProjectNode node) matchesFilter,
  bool filterActive = false,
  TH2ElementRowsCallback? th2ElementRowsFor,
}) {
  if (!filterActive) {
    return _flattenWithoutFilter(
      root: root,
      isExpanded: isExpanded,
      th2ElementRowsFor: th2ElementRowsFor,
    );
  }

  final Map<TH2FileNode, TH2ElementRowsResult> th2Results =
      <TH2FileNode, TH2ElementRowsResult>{};

  TH2ElementRowsResult? th2ResultFor(TH2FileNode node, int depth) {
    if (th2ElementRowsFor == null) {
      return null;
    }

    return th2Results.putIfAbsent(
      node,
      () => th2ElementRowsFor(node, depth, filterActive: true),
    );
  }

  final Map<THProjectNode, bool> subtreeMatches = _collectSubtreeMatches(
    root,
    matchesFilter,
    th2ResultFor,
  );
  final List<THProjectTreeVisibleRow> visibleRows =
      <THProjectTreeVisibleRow>[];

  void visit(THProjectNode node, int depth) {
    if (subtreeMatches[node] != true) {
      return;
    }

    visibleRows.add(THProjectTreeNodeRow(node: node, depth: depth));

    if (node is TH2FileNode) {
      visibleRows.addAll(
        th2ResultFor(node, depth)?.rows ?? const <THProjectTreeVisibleRow>[],
      );

      return;
    }

    for (final THProjectNode child in node.children) {
      visit(child, depth + 1);
    }
  }

  visit(root, 0);

  return visibleRows;
}

List<THProjectTreeVisibleRow> _flattenWithoutFilter({
  required THProjectNode root,
  required bool Function(THProjectNode node) isExpanded,
  TH2ElementRowsCallback? th2ElementRowsFor,
}) {
  final List<THProjectTreeVisibleRow> visibleRows =
      <THProjectTreeVisibleRow>[];

  void visit(THProjectNode node, int depth) {
    visibleRows.add(THProjectTreeNodeRow(node: node, depth: depth));

    if (!isExpanded(node)) {
      return;
    }

    if ((node is TH2FileNode) && (th2ElementRowsFor != null)) {
      visibleRows.addAll(
        th2ElementRowsFor(node, depth, filterActive: false).rows,
      );

      return;
    }

    for (final THProjectNode child in node.children) {
      visit(child, depth + 1);
    }
  }

  visit(root, 0);

  return visibleRows;
}

Map<THProjectNode, bool> _collectSubtreeMatches(
  THProjectNode root,
  bool Function(THProjectNode node) matchesFilter,
  TH2ElementRowsResult? Function(TH2FileNode node, int depth) th2ResultFor,
) {
  final Map<THProjectNode, bool> result = <THProjectNode, bool>{};

  bool visit(THProjectNode node, int depth) {
    bool hasMatch = matchesFilter(node);

    if ((node is TH2FileNode) &&
        (th2ResultFor(node, depth)?.hasMatch ?? false)) {
      hasMatch = true;
    }

    for (final THProjectNode child in node.children) {
      if (visit(child, depth + 1)) {
        hasMatch = true;
      }
    }

    result[node] = hasMatch;

    return hasMatch;
  }

  visit(root, 0);

  return result;
}
