// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_project/th_config_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_data_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';

/// Pure helpers backing [THProjectControllerBase]'s incremental re-parsing.
///
/// Kept free of MobX/controller state so the tree-diffing and index-rebuild
/// logic can be unit-tested without constructing a store, mirroring the
/// separation already used for `THProjectPathResolver` in Phase 2.
///
/// All tree walks below guard against revisiting a node: `THProjectParser`
/// deliberately re-links an already-visited node when it detects a circular
/// `source`/`input` chain (see its "Cycle detected" warning), which makes a
/// node its own descendant. A naive recursive walk over such a tree would
/// recurse forever.

/// Whether [filePath]'s edit must fall back to a full [reloadProject] instead
/// of a local branch splice.
bool shouldFullReloadForReparse({
  required bool hasProjectRoot,
  required bool isRootFile,
  required bool isKnownFile,
  required bool typeChanged,
}) {
  return !hasProjectRoot || isRootFile || !isKnownFile || typeChanged;
}

/// Walks [node]'s subtree (including [node] itself) collecting every
/// [THProjectFileNode] keyed by its canonical path.
///
/// Used to build the reuse cache passed to
/// `THProjectParser.spliceFileNodeChildren` so that includes whose target
/// file did not change keep their already-parsed subtree instead of being
/// re-read from disk.
Map<String, THProjectFileNode> collectDescendantFileNodes(
  THProjectNode node,
) {
  final Map<String, THProjectFileNode> result = <String, THProjectFileNode>{};
  final Set<THProjectNode> visited = Set<THProjectNode>.identity();

  void visit(THProjectNode current) {
    if (!visited.add(current)) {
      return;
    }

    if (current is THProjectFileNode) {
      result[current.absolutePath] = current;
    }

    for (final THProjectNode child in current.children) {
      visit(child);
    }
  }

  visit(node);

  return result;
}

/// Rebuilds [nodesByCanonicalPath] and [nodesById] in place from a full walk
/// of the tree rooted at [root].
///
/// The whole project tree is small enough, and walking it is cheap enough
/// relative to disk I/O and PetitParser re-parsing, that re-deriving these
/// indexes from scratch after every load/splice is simpler and less
/// error-prone than incrementally patching them.
void rebuildProjectIndexes({
  required THProjectFileNode root,
  required Map<String, THProjectFileNode> nodesByCanonicalPath,
  required Map<String, THProjectNode> nodesById,
}) {
  nodesByCanonicalPath.clear();
  nodesById.clear();

  final Set<THProjectNode> visited = Set<THProjectNode>.identity();

  void visit(THProjectNode current) {
    if (!visited.add(current)) {
      return;
    }

    nodesById[current.id] = current;

    if (current is THProjectFileNode) {
      nodesByCanonicalPath[current.absolutePath] = current;
    }

    for (final THProjectNode child in current.children) {
      visit(child);
    }
  }

  visit(root);
}

/// Rebuilds [fileDependencies] and [reverseDependencies] in place from a full
/// walk of the tree rooted at [root].
///
/// A forward-dependency edge exists from a file node's canonical path to
/// each descendant file node reached without passing through another file
/// node in between (mirroring `THProjectParser._addDependency`, which
/// records edges between including/included files regardless of how deeply
/// an `input` directive is nested inside surveys). Only `THConfigFileNode`
/// and `THDataFileNode` get their own (possibly empty) forward-dependency
/// entry, matching `THProjectParser`, which never registers one for leaf
/// `.th2`/missing-file nodes.
void rebuildDependencyMaps({
  required THProjectFileNode root,
  required Map<String, Set<String>> fileDependencies,
  required Map<String, Set<String>> reverseDependencies,
}) {
  fileDependencies.clear();
  reverseDependencies.clear();

  final Set<THProjectNode> visited = Set<THProjectNode>.identity();

  void visit(THProjectNode current, String? containingFilePath) {
    if (!visited.add(current)) {
      return;
    }

    String? nextContext = containingFilePath;

    if (current is THProjectFileNode) {
      if ((current is THConfigFileNode) || (current is THDataFileNode)) {
        fileDependencies.putIfAbsent(current.absolutePath, () => <String>{});
      }

      if (containingFilePath != null) {
        fileDependencies[containingFilePath]!.add(current.absolutePath);
        reverseDependencies
            .putIfAbsent(current.absolutePath, () => <String>{})
            .add(containingFilePath);
      }

      nextContext = current.absolutePath;
    }

    for (final THProjectNode child in current.children) {
      visit(child, nextContext);
    }
  }

  visit(root, null);
}

/// Collects every [THProjectNode.parseErrors] entry from the tree rooted at
/// [root], in tree (depth-first, pre-order) traversal order.
List<THProjectParseError> collectTreeErrors(THProjectNode root) {
  final List<THProjectParseError> errors = <THProjectParseError>[];
  final Set<THProjectNode> visited = Set<THProjectNode>.identity();

  void visit(THProjectNode current) {
    if (!visited.add(current)) {
      return;
    }

    errors.addAll(current.parseErrors);

    for (final THProjectNode child in current.children) {
      visit(child);
    }
  }

  visit(root);

  return errors;
}

/// Returns the entries of [resultProjectErrors] that are not attached to any
/// node in [treeErrors] (compared by identity).
///
/// `THProjectParser` records project-level-only diagnostics — currently just
/// cycle-detection warnings — in its result's `projectErrors` list without
/// attaching them to a node's own `parseErrors`. This recovers exactly those
/// entries so they are not lost when `projectErrors` is rebuilt from a tree
/// walk after a splice.
List<THProjectParseError> looseProjectErrors({
  required List<THProjectParseError> resultProjectErrors,
  required List<THProjectParseError> treeErrors,
}) {
  final Set<THProjectParseError> attached = Set<THProjectParseError>.identity()
    ..addAll(treeErrors);

  return resultProjectErrors
      .where((THProjectParseError error) => !attached.contains(error))
      .toList();
}
