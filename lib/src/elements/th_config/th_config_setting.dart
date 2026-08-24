// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_config/th_config_element.dart';

/// Represents global setting directives in a thconfig file
/// (e.g. `cs`, `encoding`, `language`, `system`, `maps`, `scrap-sort`, etc.).
class THConfigSetting extends THConfigElement {
  final String keyword;

  final List<String> arguments = <String>[];

  THConfigSetting({
    required this.keyword,
    List<String>? arguments,
    super.lineNumber,
    super.originalLine,
    super.isModified,
  }) {
    if (arguments != null) {
      this.arguments.addAll(arguments);
    }
  }

  String get argumentString => arguments.join(' ');
}
