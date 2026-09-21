// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui' as ui;

/// A resolved Therion area pattern tile builder/color/clean-flag, keyed by
/// `(MPTherionSymbolSet, THAreaType)` via `getTherionAreaPatternDefinition`.
class MPTherionAreaPatternDefinition {
  const MPTherionAreaPatternDefinition({
    required this.tileBuilder,
    required this.color,
    required this.cleanBeforeFill,
  });

  final ui.Image Function(ui.Color color) tileBuilder;
  final ui.Color color;
  final bool cleanBeforeFill;
}
