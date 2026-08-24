// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_data_element.dart';

/// Represents an  directive in a .th file.
class THEquate extends THDataElement {
  final List<String> stations = <String>[];

  THEquate({
    required List<String> stations,
    super.lineNumber,
    super.originalLine,
    super.isModified,
  }) {
    this.stations.addAll(stations);
  }
}
