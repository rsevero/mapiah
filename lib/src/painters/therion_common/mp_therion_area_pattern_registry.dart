// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/painters/therion_aut/mp_therion_aut_area_map.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_area_pattern_definition.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_default_symbol_set.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_therion_skbb_area_map.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_uis_area_map.dart';
import 'package:mapiah/src/painters/types/mp_therion_symbol_set.dart';

/// Set-specific area pattern tile lookup. Registered per set as non-UIS
/// sets are implemented (Phase 4B onward); every set without an entry here
/// has no set-specific tile of its own to try in step 1.
typedef MPTherionSetAreaPatternLookup =
    MPTherionAreaPatternDefinition? Function(THAreaType areaType);

const Map<MPTherionSymbolSet, MPTherionSetAreaPatternLookup>
_setSpecificAreaPatternLookups =
    <MPTherionSymbolSet, MPTherionSetAreaPatternLookup>{
      MPTherionSymbolSet.uis: getTherionUISAreaPatternDefinition,
      MPTherionSymbolSet.skbb: getTherionSKBBAreaPatternDefinition,
      MPTherionSymbolSet.aut: getTherionAUTAreaPatternDefinition,
    };

/// Resolves the area pattern tile definition for [areaType] under [set],
/// following `thTrans.mp`'s real dispatch order: (1) an explicit
/// symbol-set override, if selected and it defines this tile; (2)
/// `thTrans.mp`'s own default set for this area type, if known and
/// ported; (3) UIS as a last-resort catch-all. [set] is null for
/// `therionDefault` ("no `symbol-set` override" — skip straight to step
/// 2). Returns null only when none of the three steps finds a tile, in
/// which case the caller keeps the plain solid/semi-transparent fill.
MPTherionAreaPatternDefinition? getTherionAreaPatternDefinition({
  MPTherionSymbolSet? set,
  required THAreaType areaType,
}) {
  if (set != null) {
    final MPTherionSetAreaPatternLookup? setLookup =
        _setSpecificAreaPatternLookups[set];

    if (setLookup != null) {
      final MPTherionAreaPatternDefinition? chosenSetDefinition = setLookup(
        areaType,
      );

      if (chosenSetDefinition != null) {
        return chosenSetDefinition;
      }
    }
  }

  final MPTherionSymbolSet? defaultSet = getTherionDefaultAreaSet(areaType);

  if (defaultSet != null) {
    final MPTherionSetAreaPatternLookup? defaultLookup =
        _setSpecificAreaPatternLookups[defaultSet];

    if (defaultLookup != null) {
      final MPTherionAreaPatternDefinition? defaultSetDefinition =
          defaultLookup(areaType);

      if (defaultSetDefinition != null) {
        return defaultSetDefinition;
      }
    }
  }

  return getTherionUISAreaPatternDefinition(areaType);
}
