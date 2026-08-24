// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_config/th_config_element.dart';

/// Represents a comment line (`# ...`) or empty line in a thconfig file.
class THConfigComment extends THConfigElement {
  final String commentText;

  final bool isEmptyLine;

  THConfigComment({
    required this.commentText,
    this.isEmptyLine = false,
    super.lineNumber,
    super.originalLine,
    super.isModified,
  });
}
