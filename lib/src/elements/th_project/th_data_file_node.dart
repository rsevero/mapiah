// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_data_file.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';

/// File node wrapping a parsed Therion survey data (`.th`) file.
class THDataFileNode extends THProjectFileNode {
  final THDataFile dataFile;

  THDataFileNode({
    required this.dataFile,
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
