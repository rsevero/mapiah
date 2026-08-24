// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_data/th_data_element.dart';

/// Represents a general single-line statement not otherwise modeled
/// (e.g. `cs`, `declination`, `title`, `data`, `units`, `flags`, ...).
class THDataGeneral extends THDataElement {
  final String keyword;

  final String rawArguments;

  THDataGeneral({
    required this.keyword,
    this.rawArguments = '',
    super.lineNumber,
    super.originalLine,
    super.isModified,
  });
}
