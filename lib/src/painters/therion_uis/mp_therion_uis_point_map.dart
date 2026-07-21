// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';

/// Therion UIS point types with a Phase 1 or Phase 2 Dart symbol drawing.
/// Point types absent from this map keep Mapiah's placeholder rendering
/// even when the Therion UIS visualization method is selected, until later
/// phases port their (medium/complex) symbols.
const Map<THPointType, MPTherionPointSymbol> therionUISPointSymbols = {
  THPointType.anastomosis: MPTherionPointSymbol.anastomosisUIS,
  THPointType.archeoMaterial: MPTherionPointSymbol.archeoMaterialUIS,
  THPointType.camp: MPTherionPointSymbol.campUIS,
  THPointType.continuation: MPTherionPointSymbol.continuationUIS,
  THPointType.crystal: MPTherionPointSymbol.crystalUIS,
  THPointType.curtain: MPTherionPointSymbol.curtainUIS,
  THPointType.disk: MPTherionPointSymbol.diskUIS,
  THPointType.dig: MPTherionPointSymbol.digUIS,
  THPointType.entrance: MPTherionPointSymbol.entranceUIS,
  THPointType.flowstone: MPTherionPointSymbol.flowstoneUIS,
  THPointType.flute: MPTherionPointSymbol.fluteUIS,
  THPointType.gradient: MPTherionPointSymbol.gradientUIS,
  THPointType.guano: MPTherionPointSymbol.guanoUIS,
  THPointType.helictite: MPTherionPointSymbol.helictiteUIS,
  THPointType.ice: MPTherionPointSymbol.iceUIS,
  THPointType.karren: MPTherionPointSymbol.karrenUIS,
  THPointType.lowEnd: MPTherionPointSymbol.lowEndUIS,
  THPointType.moonmilk: MPTherionPointSymbol.moonmilkUIS,
  THPointType.narrowEnd: MPTherionPointSymbol.narrowEndUIS,
  THPointType.paleoMaterial: MPTherionPointSymbol.paleoMaterialUIS,
  THPointType.pebbles: MPTherionPointSymbol.pebblesUIS,
  THPointType.pillar: MPTherionPointSymbol.pillarUIS,
  THPointType.popcorn: MPTherionPointSymbol.popcornUIS,
  THPointType.sand: MPTherionPointSymbol.sandUIS,
  THPointType.scallop: MPTherionPointSymbol.scallopUIS,
  THPointType.sodaStraw: MPTherionPointSymbol.sodaStrawUIS,
  THPointType.stalactite: MPTherionPointSymbol.stalactiteUIS,
  THPointType.stalagmite: MPTherionPointSymbol.stalagmiteUIS,
  THPointType.wallCalcite: MPTherionPointSymbol.wallCalciteUIS,
};

/// Resolves symbols whose Therion macro depends on a point subtype.
MPTherionPointSymbol? getTherionUISPointSymbol({
  required THPointType pointType,
  required String subtype,
}) {
  if (pointType != THPointType.waterFlow) {
    return therionUISPointSymbols[pointType];
  }

  switch (subtype) {
    case 'intermittent':
      return MPTherionPointSymbol.waterFlowIntermittentUIS;
    case 'paleo':
      return MPTherionPointSymbol.waterFlowPaleoUIS;
    case 'permanent':
    default:
      return MPTherionPointSymbol.waterFlowPermanentUIS;
  }
}
