// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';

/// A Therion UIS point symbol's own paint definition — independent of
/// `THPointPaint`, which belongs to Mapiah's placeholder renderer. Exactly
/// the fields a symbol's `.mp` macro actually uses (`thfill`/`thdraw`) are
/// non-null, so a draw method never has to guess which pass it's in.
class MPTherionSymbolPaint {
  const MPTherionSymbolPaint({this.border, this.fill});

  final Paint? border;
  final Paint? fill;
}

/// One entry per [MPTherionPointSymbol], transcribed from `thPoint.mp`:
/// [MPTherionSymbolPaint.border] is set whenever the macro `thdraw`s,
/// [MPTherionSymbolPaint.fill] whenever it `thfill`s (directly or, for
/// [MPTherionPointSymbol.waterFlowIntermittentUIS], by delegating to
/// [MPTherionPointSymbol.waterFlowPermanentUIS]). Colors match what each
/// symbol already rendered with (borrowed from its point type's
/// placeholder paint before this file existed); this map is now their
/// sole, independent source, free to diverge from the placeholder's
/// colors in the future.
final Map<MPTherionPointSymbol, MPTherionSymbolPaint> mpTherionSymbolPaints = {
  MPTherionPointSymbol.airDraughtUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint9,
  ),
  MPTherionPointSymbol.airDraughtWinterUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint9,
  ),
  MPTherionPointSymbol.airDraughtSummerUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint9,
  ),
  MPTherionPointSymbol.anastomosisUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint1,
  ),
  MPTherionPointSymbol.archeoMaterialUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint16,
  ),
  MPTherionPointSymbol.blocksUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint1,
  ),
  MPTherionPointSymbol.campUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint10,
    fill: THPaint.thPaint1010,
  ),
  MPTherionPointSymbol.continuationUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint0,
  ),
  MPTherionPointSymbol.crystalUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint12,
  ),
  MPTherionPointSymbol.curtainUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint5,
  ),
  MPTherionPointSymbol.curtainsUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint5,
  ),
  MPTherionPointSymbol.debrisUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint12,
  ),
  MPTherionPointSymbol.discPillarUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint11,
  ),
  MPTherionPointSymbol.discPillarsUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint11,
  ),
  MPTherionPointSymbol.discStalactiteUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint13,
  ),
  MPTherionPointSymbol.discStalactitesUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint13,
  ),
  MPTherionPointSymbol.discStalagmiteUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint13,
  ),
  MPTherionPointSymbol.discStalagmitesUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint13,
  ),
  MPTherionPointSymbol.diskUIS: MPTherionSymbolPaint(border: THPaint.thPaint12),
  MPTherionPointSymbol.digUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint16,
    fill: THPaint.thPaint1016,
  ),
  MPTherionPointSymbol.entranceUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint2,
    fill: THPaint.thPaint1002,
  ),
  MPTherionPointSymbol.flowstoneUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint12,
  ),
  MPTherionPointSymbol.fluteUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint12,
  ),
  MPTherionPointSymbol.gradientUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint1,
    fill: THPaint.thPaint1001,
  ),
  MPTherionPointSymbol.guanoUIS: MPTherionSymbolPaint(border: THPaint.thPaint8),
  MPTherionPointSymbol.helictiteUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint5,
  ),
  MPTherionPointSymbol.helictitesUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint5,
  ),
  MPTherionPointSymbol.iceUIS: MPTherionSymbolPaint(border: THPaint.thPaint6),
  MPTherionPointSymbol.karrenUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint1,
  ),
  MPTherionPointSymbol.lowEndUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint2,
  ),
  MPTherionPointSymbol.moonmilkUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint12,
  ),
  MPTherionPointSymbol.narrowEndUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint2,
  ),
  // Fill-only: p_paleomaterial_UIS has no thdraw at all.
  MPTherionPointSymbol.paleoMaterialUIS: MPTherionSymbolPaint(
    fill: THPaint.thPaint1016,
  ),
  MPTherionPointSymbol.pebblesUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint1,
  ),
  MPTherionPointSymbol.pillarUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint11,
  ),
  MPTherionPointSymbol.pillarsUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint11,
  ),
  MPTherionPointSymbol.pillarWithCurtainsUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint11,
  ),
  MPTherionPointSymbol.pillarsWithCurtainsUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint11,
  ),
  MPTherionPointSymbol.popcornUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint12,
    fill: THPaint.thPaint1012,
  ),
  MPTherionPointSymbol.sandUIS: MPTherionSymbolPaint(border: THPaint.thPaint1),
  MPTherionPointSymbol.scallopUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint1,
  ),
  MPTherionPointSymbol.sodaStrawUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint5,
  ),
  MPTherionPointSymbol.stalactiteUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint13,
  ),
  MPTherionPointSymbol.stalactitesUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint13,
  ),
  MPTherionPointSymbol.stalactiteStalagmiteUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint13,
  ),
  MPTherionPointSymbol.stalactitesStalagmitesUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint13,
  ),
  MPTherionPointSymbol.stalagmiteUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint13,
  ),
  MPTherionPointSymbol.stalagmitesUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint13,
  ),
  MPTherionPointSymbol.wallCalciteUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint12,
  ),
  // p_waterflow_intermittent_UIS delegates its fill behaviour to
  // p_waterflow_permanent_UIS (thdrawoptions(dashed ...); p_waterflow_
  // permanent_UIS(...)), so it's fill-and-border too, not border-only.
  MPTherionPointSymbol.waterFlowIntermittentUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint14,
    fill: THPaint.thPaint1014,
  ),
  MPTherionPointSymbol.waterFlowPaleoUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint14,
    fill: THPaint.thPaint1014,
  ),
  MPTherionPointSymbol.waterFlowPermanentUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint14,
    fill: THPaint.thPaint1014,
  ),
  MPTherionPointSymbol.waterUIS: MPTherionSymbolPaint(
    border: THPaint.thPaint3,
    fill: THPaint.thPaint1003,
  ),

  // SKBB (Phase 4B): border/fill borrowed from each point type's
  // placeholder paint (mp_visual_controller.dart's pointTypePaints), kept
  // only where the p_*_SKBB macro actually thdraw/thfill's.
  MPTherionPointSymbol.anchorSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint10,
  ),
  MPTherionPointSymbol.boreholeSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint7,
    fill: THPaint.thPaint1007,
  ),
  MPTherionPointSymbol.bridgeSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint10,
  ),
  MPTherionPointSymbol.campSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint10,
  ),
  MPTherionPointSymbol.cavePearlSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint12,
  ),
  MPTherionPointSymbol.claySKBB: MPTherionSymbolPaint(border: THPaint.thPaint1),
  MPTherionPointSymbol.fixedLadderSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint10,
  ),
  MPTherionPointSymbol.gradientSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint1,
  ),
  MPTherionPointSymbol.noEquipmentSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint0,
    fill: THPaint.thPaint1000,
  ),
  MPTherionPointSymbol.ropeLadderSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint10,
  ),
  MPTherionPointSymbol.ropeSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint10,
  ),
  MPTherionPointSymbol.sinkSKBB: MPTherionSymbolPaint(border: THPaint.thPaint3),
  MPTherionPointSymbol.snowSKBB: MPTherionSymbolPaint(border: THPaint.thPaint6),
  MPTherionPointSymbol.springSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint3,
  ),
  MPTherionPointSymbol.stepsSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint10,
  ),
  MPTherionPointSymbol.traverseSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint1,
  ),
  MPTherionPointSymbol.viaFerrataSKBB: MPTherionSymbolPaint(
    border: THPaint.thPaint10,
  ),
};
