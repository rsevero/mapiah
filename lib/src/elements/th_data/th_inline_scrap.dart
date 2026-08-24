// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_data_element.dart';

/// Represents an inline  block in a .th file.
class THInlineScrap extends THDataElement {
  final String scrapId;

  final String projection;

  final List<String> rawLines = <String>[];

  final Map<String, dynamic> parsedOptions = <String, dynamic>{};

  THInlineScrap({
    required this.scrapId,
    this.projection = 'plan',
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
