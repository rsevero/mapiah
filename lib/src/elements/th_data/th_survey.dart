// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_data_element.dart';

/// Represents a  hierarchical block in a .th file.
class THSurvey extends THDataElement {
  final String surveyId;

  final String? title;

  final Map<String, dynamic> parsedOptions = <String, dynamic>{};

  final List<THDataElement> children = <THDataElement>[];

  /// Original text of the closing `endsurvey` line, preserved verbatim.
  String endLine;

  THSurvey({
    required this.surveyId,
    this.title,
    Map<String, dynamic>? parsedOptions,
    List<THDataElement>? children,
    this.endLine = '',
    super.lineNumber,
    super.originalLine,
    super.isModified,
  }) {
    if (parsedOptions != null) {
      this.parsedOptions.addAll(parsedOptions);
    }
    if (children != null) {
      this.children.addAll(children);
    }
  }
}
