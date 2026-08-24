// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';

/// File node for a `source`, `input`, or `import` target that does not exist.
class THMissingFileNode extends THProjectFileNode {
  /// The raw, unresolved path as written in the source directive.
  final String requestedPath;

  THMissingFileNode({
    required this.requestedPath,
    required super.id,
    required super.label,
    required super.sourceFilePath,
    required super.lineNumber,
    required super.absolutePath,
    required super.relativePathToProjectRoot,
    required super.encoding,
  }) : super(isLoaded: false);
}
