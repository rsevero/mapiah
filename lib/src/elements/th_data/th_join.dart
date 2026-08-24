// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_data_element.dart';

/// Represents a  directive in a .th file.
class THJoin extends THDataElement {
  final String line1;

  final String line2;

  final List<String> rawOptions = <String>[];

  final Map<String, dynamic> parsedOptions = <String, dynamic>{};

  THJoin({
    required this.line1,
    required this.line2,
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
