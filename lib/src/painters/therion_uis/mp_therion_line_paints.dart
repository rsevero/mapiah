// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:material_ui/material_ui.dart';

/// One entry per [THLineType] with a Therion UIS line decorator
/// (`MPVisualControllerBase.getLineDecorator`) — independent of the
/// `THLinePaint` used by Mapiah's unrelated placeholder line renderer.
/// `pit`/`pitch`/`floorStep` share one decorator class but keep their own
/// distinct colors, as they always have; `survey`'s `cave`/no-subtype and
/// `waterFlow`'s `permanent`/no-subtype variants already resolved to the
/// same color as each other, so keying by bare [THLineType] (no subtype)
/// loses nothing. Colors match what each decorator already rendered with
/// (borrowed from its line type's placeholder paint before this file
/// existed); this map is now their sole, independent source.
final Map<THLineType, Paint> mpTherionLineColors = {
  THLineType.ceilingMeander: THPaint.thPaint5,
  THLineType.ceilingStep: THPaint.thPaint5,
  THLineType.chimney: THPaint.thPaint13,
  THLineType.contour: THPaint.thPaint6,
  THLineType.floorStep: THPaint.thPaint5,
  THLineType.pit: THPaint.thPaint13,
  THLineType.pitch: THPaint.thPaint12,
  THLineType.flowstone: THPaint.thPaint10,
  THLineType.gradient: THPaint.thPaint12,
  THLineType.moonmilk: THPaint.thPaint10,
  THLineType.rockEdge: THPaint.thPaint8,
  THLineType.survey: THPaint.thPaint14,
  THLineType.waterFlow: THPaint.thPaint3,
};
