// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';

/// Therion SKBB point types with a Phase 4B Dart symbol drawing. Point
/// types absent from this map (including `station-name`, whose SKBB macro
/// is entangled with Therion's text-flag system, and `handrail`, whose
/// SKBB macro is sized from the survey's real-world paper scale rather
/// than the symbol unit) fall through to `thTrans.mp`'s own default set
/// for that point type (via [getTherionPointSymbol]), and only then to
/// UIS. `station` is handled separately, below, since it's subtype-aware.
const Map<THPointType, MPTherionPointSymbol> therionSKBBPointSymbols = {
  THPointType.anchor: MPTherionPointSymbol.anchorSKBB,
  THPointType.borehole: MPTherionPointSymbol.boreholeSKBB,
  THPointType.bridge: MPTherionPointSymbol.bridgeSKBB,
  THPointType.camp: MPTherionPointSymbol.campSKBB,
  THPointType.cavePearl: MPTherionPointSymbol.cavePearlSKBB,
  THPointType.clay: MPTherionPointSymbol.claySKBB,
  THPointType.fixedLadder: MPTherionPointSymbol.fixedLadderSKBB,
  THPointType.gradient: MPTherionPointSymbol.gradientSKBB,
  THPointType.noEquipment: MPTherionPointSymbol.noEquipmentSKBB,
  THPointType.rope: MPTherionPointSymbol.ropeSKBB,
  THPointType.ropeLadder: MPTherionPointSymbol.ropeLadderSKBB,
  THPointType.sink: MPTherionPointSymbol.sinkSKBB,
  THPointType.snow: MPTherionPointSymbol.snowSKBB,
  THPointType.spring: MPTherionPointSymbol.springSKBB,
  THPointType.steps: MPTherionPointSymbol.stepsSKBB,
  THPointType.traverse: MPTherionPointSymbol.traverseSKBB,
  THPointType.viaFerrata: MPTherionPointSymbol.viaFerrataSKBB,
};

/// Resolves the SKBB-specific point symbol for [pointType]/[subtype].
/// Returns null for every point type/subtype SKBB doesn't define its own
/// symbol for (including subtyped `air-draught`/`water-flow`, which SKBB
/// doesn't override), letting the caller ([getTherionPointSymbol]) fall
/// through to `thTrans.mp`'s own default set for this symbol, and only
/// then to UIS.
MPTherionPointSymbol? getTherionSKBBPointSymbol({
  required THPointType pointType,
  required String subtype,
}) {
  if (pointType == THPointType.station) {
    // Under an active `symbol-set SKBB`, Therion's `mapsymbol` mechanism
    // overrides bare `p_station_temporary` with `p_station_temporary_SKBB`
    // (== `p_station_painted_SKBB`). `station` with no subtype carries the
    // "temporary" mark by default (see `thpoint.cxx`), so `station`,
    // `station:temporary`, and `station:painted` all render as that same
    // plain circle under SKBB. `station:fixed`/`station:natural` have no
    // SKBB-specific override (they keep `p_station_fixed_ASF`/
    // `p_station_natural_ASF`, unported) so fall through instead.
    switch (subtype) {
      case 'fixed':
      case 'natural':
        return null;
      default:
        return MPTherionPointSymbol.stationPaintedSKBB;
    }
  }

  return therionSKBBPointSymbols[pointType];
}
