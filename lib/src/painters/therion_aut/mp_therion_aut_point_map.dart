// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';

/// Therion AUT point types with a Phase 4C Dart symbol drawing. Point
/// types absent from this map fall through to `thTrans.mp`'s own default
/// set for that point type (via [getTherionPointSymbol]), and only then to
/// UIS. `station` is handled separately, below, since it's subtype-aware.
const Map<THPointType, MPTherionPointSymbol> therionAUTPointSymbols = {
  THPointType.airDraught: MPTherionPointSymbol.airDraughtAUT,
  THPointType.blocks: MPTherionPointSymbol.blocksAUT,
  THPointType.breakdownChoke: MPTherionPointSymbol.breakdownChokeAUT,
  THPointType.clay: MPTherionPointSymbol.clayAUT,
  THPointType.clayChoke: MPTherionPointSymbol.clayChokeAUT,
  THPointType.clayTree: MPTherionPointSymbol.clayTreeAUT,
  THPointType.crystal: MPTherionPointSymbol.crystalAUT,
  THPointType.debris: MPTherionPointSymbol.debrisAUT,
  THPointType.entrance: MPTherionPointSymbol.entranceAUT,
  THPointType.gradient: MPTherionPointSymbol.gradientAUT,
  THPointType.ice: MPTherionPointSymbol.iceAUT,
  THPointType.icePillar: MPTherionPointSymbol.icePillarAUT,
  THPointType.iceStalactite: MPTherionPointSymbol.iceStalactiteAUT,
  THPointType.iceStalagmite: MPTherionPointSymbol.iceStalagmiteAUT,
  THPointType.pebbles: MPTherionPointSymbol.pebblesAUT,
  THPointType.pillar: MPTherionPointSymbol.pillarAUT,
  THPointType.sand: MPTherionPointSymbol.sandAUT,
  THPointType.sink: MPTherionPointSymbol.sinkAUT,
  THPointType.spring: MPTherionPointSymbol.springAUT,
  THPointType.stalactite: MPTherionPointSymbol.stalactiteAUT,
  THPointType.stalagmite: MPTherionPointSymbol.stalagmiteAUT,
  THPointType.water: MPTherionPointSymbol.waterAUT,
};

/// Resolves the AUT-specific point symbol for [pointType]/[subtype].
/// Returns null for every point type/subtype AUT doesn't define its own
/// symbol for, letting the caller ([getTherionPointSymbol]) fall through
/// to `thTrans.mp`'s own default set for this symbol, and only then to
/// UIS.
MPTherionPointSymbol? getTherionAUTPointSymbol({
  required THPointType pointType,
  required String subtype,
}) {
  if (pointType == THPointType.station) {
    // `p_station_temporary_AUT` is AUT's only own station macro;
    // `p_station_painted_AUT`/`p_station_fixed_AUT` are both `let`-aliased
    // straight to the unported `p_station_fixed_ASF`, so they fall
    // through instead (to `thTrans.mp`'s SKBB/ASF default). Bare
    // `station` carries the "temporary" mark by default (see
    // `MPTherionPointSymbolsSKBB`'s station doc comment), so it and the
    // explicit `temporary` subtype both resolve here.
    switch (subtype) {
      case mpNoSubtypeID:
      case 'temporary':
        return MPTherionPointSymbol.stationTemporaryAUT;
      default:
        return null;
    }
  }

  return therionAUTPointSymbols[pointType];
}
