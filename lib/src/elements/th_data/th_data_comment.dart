// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_data_element.dart';

/// Represents a comment line () or empty line in a .th file.
class THDataComment extends THDataElement {
  final String commentText;

  final bool isEmptyLine;

  THDataComment({
    required this.commentText,
    this.isEmptyLine = false,
    super.lineNumber,
    super.originalLine,
    super.isModified,
  });
}
