// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_data_element.dart';

/// Represents a  block in a .th file.
class THMap extends THDataElement {
  final String mapId;

  final String projection;

  final String? title;

  final List<String> items = <String>[];

  final Map<String, dynamic> parsedOptions = <String, dynamic>{};

  THMap({
    required this.mapId,
    this.projection = 'plan',
    this.title,
    List<String>? items,
    Map<String, dynamic>? parsedOptions,
    super.lineNumber,
    super.originalLine,
    super.isModified,
  }) {
    if (items != null) {
      this.items.addAll(items);
    }
    if (parsedOptions != null) {
      this.parsedOptions.addAll(parsedOptions);
    }
  }
}
