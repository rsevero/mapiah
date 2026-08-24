// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_config/th_config_element.dart';

/// Represents a `layout <id> ... endlayout` block in a thconfig file.
class THConfigLayout extends THConfigElement {
  final String layoutId;

  final List<String> rawLines = <String>[];

  final Map<String, dynamic> parsedOptions = <String, dynamic>{};

  THConfigLayout({
    required this.layoutId,
    List<String>? rawLines,
    Map<String, dynamic>? parsedOptions,
    super.lineNumber,
    super.originalLine,
    super.isModified,
  }) {
    if (rawLines != null) {
      this.rawLines.addAll(rawLines);
    }
    if (parsedOptions != null) {
      this.parsedOptions.addAll(parsedOptions);
    }
  }
}
