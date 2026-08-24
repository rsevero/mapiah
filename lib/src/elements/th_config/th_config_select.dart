// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_config/th_config_element.dart';

/// Represents a `select <object> [options]` or `unselect <object> [options]` directive in a thconfig file.
class THConfigSelect extends THConfigElement {
  final bool isSelect;

  final String targetObjectId;

  final List<String> rawOptions = <String>[];

  final Map<String, dynamic> parsedOptions = <String, dynamic>{};

  THConfigSelect({
    required this.isSelect,
    required this.targetObjectId,
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
