// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_line_definition.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_therion_skbb_line_map.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_uis_line_map.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';

/// Set-specific line decorator/color lookup. Registered per set as
/// non-UIS sets are implemented (Phase 4B onward); every set without an
/// entry here falls all the way through to the UIS decorator.
typedef MPTherionSetLineLookup =
    MPTherionLineDefinition? Function({
      required THLineType lineType,
      String? subtype,
    });

const Map<MPTherionSymbolSet, MPTherionSetLineLookup>
_setSpecificLineLookups = <MPTherionSymbolSet, MPTherionSetLineLookup>{
  MPTherionSymbolSet.skbb: getTherionSKBBLineDefinition,
};

/// Resolves the line decorator/color for [lineType]/[subtype] under [set],
/// following the fallback order set-specific → UIS. Returns null only when
/// neither the selected set nor UIS defines a decorator for this line
/// type/subtype.
MPTherionLineDefinition? getTherionLineDefinition({
  required MPTherionSymbolSet set,
  required THLineType lineType,
  String? subtype,
}) {
  final MPTherionSetLineLookup? setLookup = _setSpecificLineLookups[set];

  if (setLookup != null) {
    final MPTherionLineDefinition? setDefinition = setLookup(
      lineType: lineType,
      subtype: subtype,
    );

    if (setDefinition != null) {
      return setDefinition;
    }
  }

  return getTherionUISLineDefinition(lineType: lineType, subtype: subtype);
}
