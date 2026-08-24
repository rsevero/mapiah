// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_therion_point_symbols_skbb.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_therion_skbb_point_map.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_point_symbols_uis.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_symbol_paints.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_uis_point_map.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';

/// Set-specific, subtype-aware point symbol lookup. Registered per set as
/// non-UIS sets are implemented (Phase 4B onward); every set without an
/// entry here falls all the way through to the UIS lookup.
typedef MPTherionSetPointSymbolLookup =
    MPTherionPointSymbol? Function({
      required THPointType pointType,
      required String subtype,
    });

const Map<MPTherionSymbolSet, MPTherionSetPointSymbolLookup>
_setSpecificPointSymbolLookups = <MPTherionSymbolSet, MPTherionSetPointSymbolLookup>{
  MPTherionSymbolSet.skbb: getTherionSKBBPointSymbol,
};

/// Resolves the point symbol to draw for [pointType]/[subtype] under
/// [set], following the fallback order set-specific → UIS. Returns null
/// only when neither the selected set nor UIS defines a symbol for this
/// point type/subtype, in which case the caller keeps the Mapiah
/// placeholder rendering.
MPTherionPointSymbol? getTherionPointSymbol({
  required MPTherionSymbolSet set,
  required THPointType pointType,
  required String subtype,
}) {
  final MPTherionSetPointSymbolLookup? setLookup =
      _setSpecificPointSymbolLookups[set];

  if (setLookup != null) {
    final MPTherionPointSymbol? setSymbol = setLookup(
      pointType: pointType,
      subtype: subtype,
    );

    if (setSymbol != null) {
      return setSymbol;
    }
  }

  return getTherionUISPointSymbol(pointType: pointType, subtype: subtype);
}

/// Set-specific draw method map, merged over [MPTherionPointSymbolsUIS.
/// drawMethods]. Every [MPTherionPointSymbol] value must resolve here or in
/// the UIS map.
const Map<MPTherionPointSymbol, void Function(Canvas, Offset, double, MPTherionSymbolPaint)>
_setSpecificDrawMethods = <MPTherionPointSymbol, void Function(Canvas, Offset, double, MPTherionSymbolPaint)>{
  ...MPTherionPointSymbolsSKBB.drawMethods,
};

/// Resolves the draw method for an already-resolved [symbol]. Every
/// [MPTherionPointSymbol] value must have exactly one entry across the UIS
/// and set-specific draw method maps.
void Function(Canvas, Offset, double, MPTherionSymbolPaint)?
getTherionPointDrawMethod(MPTherionPointSymbol symbol) {
  return _setSpecificDrawMethods[symbol] ??
      MPTherionPointSymbolsUIS.drawMethods[symbol];
}
