// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_centreline.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';

/// Logical node representing a `centreline ... endcentreline` block.
class THCentrelineNode extends THProjectNode {
  final THCentreline centreline;

  THCentrelineNode({
    required this.centreline,
    required super.id,
    required super.label,
    required super.sourceFilePath,
    required super.lineNumber,
  });
}
