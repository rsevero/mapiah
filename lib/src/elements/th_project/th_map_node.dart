// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_map.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';

/// Logical node representing a `map ... endmap` block.
class THMapNode extends THProjectNode {
  final THMap map;

  THMapNode({
    required this.map,
    required super.id,
    required super.label,
    required super.sourceFilePath,
    required super.lineNumber,
  });
}
