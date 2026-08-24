// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_area_pattern_definition.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_therion_skbb_area_map.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_uis_area_map.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';

/// Set-specific area pattern tile lookup. Registered per set as non-UIS
/// sets are implemented (Phase 4B onward); every set without an entry here
/// falls all the way through to the UIS tile.
typedef MPTherionSetAreaPatternLookup =
    MPTherionAreaPatternDefinition? Function(THAreaType areaType);

const Map<MPTherionSymbolSet, MPTherionSetAreaPatternLookup>
_setSpecificAreaPatternLookups =
    <MPTherionSymbolSet, MPTherionSetAreaPatternLookup>{
      MPTherionSymbolSet.skbb: getTherionSKBBAreaPatternDefinition,
    };

/// Resolves the area pattern tile definition for [areaType] under [set],
/// following the fallback order set-specific → UIS. Returns null only when
/// neither the selected set nor UIS defines a pattern tile for this area
/// type, in which case the caller keeps the plain solid/semi-transparent
/// fill.
MPTherionAreaPatternDefinition? getTherionAreaPatternDefinition({
  required MPTherionSymbolSet set,
  required THAreaType areaType,
}) {
  final MPTherionSetAreaPatternLookup? setLookup =
      _setSpecificAreaPatternLookups[set];

  if (setLookup != null) {
    final MPTherionAreaPatternDefinition? setDefinition = setLookup(areaType);

    if (setDefinition != null) {
      return setDefinition;
    }
  }

  return getTherionUISAreaPatternDefinition(areaType);
}
