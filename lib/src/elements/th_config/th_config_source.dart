// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_config/th_config_element.dart';

/// Represents a `source <file-path>` or multi-line `source ... endsource` directive in a thconfig file.
class THConfigSource extends THConfigElement {
  final String filePath;

  final bool isMultiLine;

  final List<String> inlineCommands = <String>[];

  THConfigSource({
    this.filePath = '',
    this.isMultiLine = false,
    List<String>? inlineCommands,
    super.lineNumber,
    super.originalLine,
    super.isModified,
  }) {
    if (inlineCommands != null) {
      this.inlineCommands.addAll(inlineCommands);
    }
  }
}
