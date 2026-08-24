// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_project/th_project_node.dart';

/// Logical node representing an inline `scrap ... endscrap` block.
class THScrapNode extends THProjectNode {
  final String scrapId;

  /// True when the scrap comes from a linked `.th2` file.
  final bool isFromTH2File;

  THScrapNode({
    required this.scrapId,
    required this.isFromTH2File,
    required super.id,
    required super.label,
    required super.sourceFilePath,
    required super.lineNumber,
  });
}
