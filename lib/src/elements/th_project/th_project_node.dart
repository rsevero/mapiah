// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';

/// Base class for every node in the project hierarchy tree.
///
/// Both file nodes and logical Therion nodes inherit from this class.
abstract class THProjectNode {
  /// Stable synthetic id, e.g. `file:<absolutePath>` or
  /// `survey:<absolutePath>:<lineNumber>`.
  final String id;

  final String label;

  /// Absolute path of the file this node's definition lives in.
  final String sourceFilePath;

  final int lineNumber;

  final List<THProjectNode> children = <THProjectNode>[];

  THProjectNode? parent;

  final List<THProjectParseError> parseErrors = <THProjectParseError>[];

  bool get hasErrors => parseErrors.isNotEmpty;

  THProjectNode({
    required this.id,
    required this.label,
    required this.sourceFilePath,
    required this.lineNumber,
  });

  void addChild(THProjectNode child) {
    child.parent = this;
    children.add(child);
  }
}
