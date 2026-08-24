// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_project/th_project_node.dart';

/// Base class for nodes that represent a file in a Therion project tree.
abstract class THProjectFileNode extends THProjectNode {
  final String absolutePath;

  final String relativePathToProjectRoot;

  final String encoding;

  bool isLoaded;

  THProjectFileNode({
    required super.id,
    required super.label,
    required super.sourceFilePath,
    required super.lineNumber,
    required this.absolutePath,
    required this.relativePathToProjectRoot,
    required this.encoding,
    this.isLoaded = false,
  });
}
