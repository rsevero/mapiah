// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_default_symbol_set.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_line_definition.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_therion_skbb_line_map.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_uis_line_map.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';

/// Set-specific line decorator/color lookup. Registered per set as
/// non-UIS sets are implemented (Phase 4B onward); every set without an
/// entry here has no set-specific decorator of its own to try in step 1.
typedef MPTherionSetLineLookup =
    MPTherionLineDefinition? Function({
      required THLineType lineType,
      String? subtype,
    });

const Map<MPTherionSymbolSet, MPTherionSetLineLookup>
_setSpecificLineLookups = <MPTherionSymbolSet, MPTherionSetLineLookup>{
  MPTherionSymbolSet.uis: getTherionUISLineDefinition,
  MPTherionSymbolSet.skbb: getTherionSKBBLineDefinition,
};

/// Resolves the line decorator/color for [lineType]/[subtype] under
/// [set], following `thTrans.mp`'s real dispatch order: (1) an explicit
/// symbol-set override, if selected and it defines this decorator; (2)
/// `thTrans.mp`'s own default set for this line type/subtype, if known
/// and ported; (3) UIS as a last-resort catch-all. [set] is null for
/// `therionDefault` ("no `symbol-set` override" — skip straight to step
/// 2). Returns null only when none of the three steps finds a decorator.
MPTherionLineDefinition? getTherionLineDefinition({
  MPTherionSymbolSet? set,
  required THLineType lineType,
  String? subtype,
}) {
  if (set != null) {
    final MPTherionSetLineLookup? setLookup = _setSpecificLineLookups[set];

    if (setLookup != null) {
      final MPTherionLineDefinition? chosenSetDefinition = setLookup(
        lineType: lineType,
        subtype: subtype,
      );

      if (chosenSetDefinition != null) {
        return chosenSetDefinition;
      }
    }
  }

  final MPTherionSymbolSet? defaultSet = getTherionDefaultLineSet(
    lineType: lineType,
    subtype: subtype,
  );

  if (defaultSet != null) {
    final MPTherionSetLineLookup? defaultLookup =
        _setSpecificLineLookups[defaultSet];

    if (defaultLookup != null) {
      final MPTherionLineDefinition? defaultSetDefinition = defaultLookup(
        lineType: lineType,
        subtype: subtype,
      );

      if (defaultSetDefinition != null) {
        return defaultSetDefinition;
      }
    }
  }

  return getTherionUISLineDefinition(lineType: lineType, subtype: subtype);
}
