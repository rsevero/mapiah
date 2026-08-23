// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:material_ui/material_ui.dart';

/// One entry per [THAreaType] with a Therion UIS pattern tile
/// (`MPVisualControllerBase._getTherionUISAreaPatternPaint`) — independent
/// of the `THLinePaint` used by Mapiah's unrelated placeholder area
/// renderer. Colors match what each pattern already rendered with (`sand`
/// was already independent of the placeholder; the rest were borrowed from
/// their area type's placeholder paint before this file existed); this map
/// is now their sole, independent source.
final Map<THAreaType, Color> mpTherionAreaPatternColors = {
  THAreaType.water: THPaint.thPaint3.color,
  THAreaType.sump: THPaint.thPaint14.color,
  THAreaType.debris: THPaint.thPaint12.color,
  THAreaType.flowstone: THPaint.thPaint6.color,
  THAreaType.moonmilk: THPaint.thPaint6.color,
  THAreaType.sand: const Color(0xFF000000),
};
