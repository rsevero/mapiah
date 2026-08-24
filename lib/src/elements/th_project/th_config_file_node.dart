// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_config/th_config_file.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';

/// File node wrapping a parsed Therion configuration (`thconfig`) file.
class THConfigFileNode extends THProjectFileNode {
  final THConfigFile configFile;

  THConfigFileNode({
    required this.configFile,
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
