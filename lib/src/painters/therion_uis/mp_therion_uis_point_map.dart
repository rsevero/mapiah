// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';

/// Therion UIS point types with a Phase 1 (simple) Dart symbol drawing.
/// Point types absent from this map keep Mapiah's placeholder rendering
/// even when the Therion UIS visualization method is selected, until later
/// phases port their (medium/complex) symbols.
const Map<THPointType, MPTherionPointSymbol> therionUISPointSymbols = {
  THPointType.continuation: MPTherionPointSymbol.continuationUIS,
  THPointType.crystal: MPTherionPointSymbol.crystalUIS,
  THPointType.dig: MPTherionPointSymbol.digUIS,
  THPointType.entrance: MPTherionPointSymbol.entranceUIS,
  THPointType.flowstone: MPTherionPointSymbol.flowstoneUIS,
  THPointType.flute: MPTherionPointSymbol.fluteUIS,
  THPointType.ice: MPTherionPointSymbol.iceUIS,
  THPointType.karren: MPTherionPointSymbol.karrenUIS,
  THPointType.lowEnd: MPTherionPointSymbol.lowEndUIS,
  THPointType.narrowEnd: MPTherionPointSymbol.narrowEndUIS,
  THPointType.pillar: MPTherionPointSymbol.pillarUIS,
  THPointType.sand: MPTherionPointSymbol.sandUIS,
  THPointType.sodaStraw: MPTherionPointSymbol.sodaStrawUIS,
  THPointType.stalactite: MPTherionPointSymbol.stalactiteUIS,
  THPointType.stalagmite: MPTherionPointSymbol.stalagmiteUIS,
  THPointType.wallCalcite: MPTherionPointSymbol.wallCalciteUIS,
};
