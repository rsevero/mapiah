// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_config/th_config_element.dart';

/// Represents an `export <type> [options]` directive in a thconfig file.
class THConfigExport extends THConfigElement {
  final String exportType;

  final String? outputFilePath;

  final String? layoutId;

  final String? projection;

  final List<String> rawOptions = <String>[];

  final Map<String, dynamic> parsedOptions = <String, dynamic>{};

  THConfigExport({
    required this.exportType,
    this.outputFilePath,
    this.layoutId,
    this.projection,
    List<String>? rawOptions,
    Map<String, dynamic>? parsedOptions,
    super.lineNumber,
    super.originalLine,
    super.isModified,
  }) {
    if (rawOptions != null) {
      this.rawOptions.addAll(rawOptions);
    }
    if (parsedOptions != null) {
      this.parsedOptions.addAll(parsedOptions);
    }
  }
}
