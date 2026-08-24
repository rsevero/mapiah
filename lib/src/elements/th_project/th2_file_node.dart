// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';

/// Leaf file node for a linked `.th2` canvas file.
///
/// The contents are intentionally not parsed by [THProjectParser]; they are
/// loaded lazily when a canvas tab is opened.
class TH2FileNode extends THProjectFileNode {
  TH2FileNode({
    required super.id,
    required super.label,
    required super.sourceFilePath,
    required super.lineNumber,
    required super.absolutePath,
    required super.relativePathToProjectRoot,
    required super.encoding,
    super.isLoaded,
  });
}
