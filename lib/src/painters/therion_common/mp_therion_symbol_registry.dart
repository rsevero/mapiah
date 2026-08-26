// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_default_symbol_set.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_therion_point_symbols_skbb.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_therion_skbb_point_map.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_point_symbols_uis.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_symbol_paints.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_uis_point_map.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';

/// Set-specific, subtype-aware point symbol lookup. Registered per set as
/// non-UIS sets are implemented (Phase 4B onward); every set without an
/// entry here has no set-specific symbol of its own to try in step 1.
typedef MPTherionSetPointSymbolLookup =
    MPTherionPointSymbol? Function({
      required THPointType pointType,
      required String subtype,
    });

const Map<MPTherionSymbolSet, MPTherionSetPointSymbolLookup>
_setSpecificPointSymbolLookups = <MPTherionSymbolSet, MPTherionSetPointSymbolLookup>{
  MPTherionSymbolSet.uis: getTherionUISPointSymbol,
  MPTherionSymbolSet.skbb: getTherionSKBBPointSymbol,
};

/// Resolves the point symbol to draw for [pointType]/[subtype] under
/// [set], following `thTrans.mp`'s real dispatch order: (1) an explicit
/// symbol-set override, if selected and it defines this symbol; (2)
/// `thTrans.mp`'s own default set for this symbol, if known and ported;
/// (3) UIS as a last-resort catch-all. [set] is null for
/// `therionDefault` ("no `symbol-set` override" — skip straight to step
/// 2). Returns null only when none of the three steps finds a symbol, in
/// which case the caller keeps the Mapiah placeholder rendering.
MPTherionPointSymbol? getTherionPointSymbol({
  MPTherionSymbolSet? set,
  required THPointType pointType,
  required String subtype,
}) {
  if (set != null) {
    final MPTherionSetPointSymbolLookup? setLookup =
        _setSpecificPointSymbolLookups[set];

    if (setLookup != null) {
      final MPTherionPointSymbol? chosenSetSymbol = setLookup(
        pointType: pointType,
        subtype: subtype,
      );

      if (chosenSetSymbol != null) {
        return chosenSetSymbol;
      }
    }
  }

  final MPTherionSymbolSet? defaultSet = getTherionDefaultPointSet(
    pointType: pointType,
    subtype: subtype,
  );

  if (defaultSet != null) {
    final MPTherionSetPointSymbolLookup? defaultLookup =
        _setSpecificPointSymbolLookups[defaultSet];

    if (defaultLookup != null) {
      final MPTherionPointSymbol? defaultSetSymbol = defaultLookup(
        pointType: pointType,
        subtype: subtype,
      );

      if (defaultSetSymbol != null) {
        return defaultSetSymbol;
      }
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
