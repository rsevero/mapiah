// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_survey.dart';
import 'package:mapiah/src/elements/th_project/th_project_node.dart';

/// Logical node representing a `survey ... endsurvey` block in a `.th` file.
class THSurveyNode extends THProjectNode {
  final THSurvey survey;

  /// Leaf-to-root namespace, e.g. `passage.cave`.
  final String fullNamespace;

  THSurveyNode({
    required this.survey,
    required this.fullNamespace,
    required super.id,
    required super.label,
    required super.sourceFilePath,
    required super.lineNumber,
  });
}
