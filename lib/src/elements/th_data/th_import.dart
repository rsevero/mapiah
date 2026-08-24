// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_data_element.dart';

/// Represents an  directive in a .th file.
class THImport extends THDataElement {
  final String filePath;

  final List<String> rawOptions = <String>[];

  final Map<String, dynamic> parsedOptions = <String, dynamic>{};

  THImport({
    required this.filePath,
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
