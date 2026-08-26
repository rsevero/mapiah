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
///
/// [THLineType.wall] has no UIS decorator of its own (wall subtypes stay
/// on the placeholder `THLinePaint` under UIS) — its entry here is used
/// only by the SKBB-specific wall decorators, which share this same map
/// rather than keeping a second, SKBB-only color table.
///
/// [THLineType.ropeLadder]/[THLineType.viaFerrata] are the same: Therion
/// has no separate UIS macro for either (`l_ropeladder`/`l_viaferrata`
/// alias straight to their `_SKBB` definitions in `thTrans.mp`), so these
/// entries are used only by the SKBB decorators.
///
/// [THLineType.slope] is the same again: `l_slope` aliases straight to
/// `l_slope_SKBB` in `thTrans.mp` with no separate UIS macro, so this entry
/// is used only by the SKBB decorator.
///
/// [THLineType.fixedLadder]/[THLineType.handrail]/[THLineType.mapConnection]/
/// [THLineType.rope]/[THLineType.steps] follow the same pattern again:
/// `thTrans.mp` aliases each straight to its `_SKBB` definition with no
/// separate UIS macro, and none of their macros call `withcolor`, so they
/// use Therion's plain default (black), same as [THLineType.slope]/
/// [THLineType.wall]. [THLineType.steps]'s own decorator ignores this
/// entry's color in its "invalid stairs definition" fallback, which is
/// forced red in `thLine.mp` regardless of the line's assigned color.
final Map<THLineType, Paint> mpTherionLineColors = {
  THLineType.ceilingMeander: THPaint.thPaint5,
  THLineType.ceilingStep: THPaint.thPaint5,
  THLineType.chimney: THPaint.thPaint13,
  THLineType.contour: THPaint.thPaint6,
  THLineType.fixedLadder: THPaint.thPaint0,
  THLineType.floorStep: THPaint.thPaint5,
  THLineType.handrail: THPaint.thPaint0,
  THLineType.mapConnection: THPaint.thPaint0,
  THLineType.pit: THPaint.thPaint13,
  THLineType.pitch: THPaint.thPaint12,
  THLineType.flowstone: THPaint.thPaint10,
  THLineType.gradient: THPaint.thPaint12,
  THLineType.moonmilk: THPaint.thPaint10,
  THLineType.rockEdge: THPaint.thPaint8,
  THLineType.rope: THPaint.thPaint0,
  THLineType.ropeLadder: THPaint.thPaintMetaPostRed,
  THLineType.slope: THPaint.thPaint0,
  THLineType.steps: THPaint.thPaint0,
  THLineType.survey: THPaint.thPaint14,
  THLineType.viaFerrata: THPaint.thPaintMetaPostRed,
  THLineType.waterFlow: THPaint.thPaint3,
  THLineType.wall: THPaint.thPaint0,
};
