// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_line_definition.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_ceiling_meander_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_ceiling_step_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_floor_meander_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_overhang_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_water_flow_conjectural_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_chimney_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_contour_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_line_paints.dart';

/// Phase 4B Therion SKBB line decorators.
///
/// `l_chimney_UIS` is defined in `thLine.mp` as `l_ceilingstep_SKBB(reverse
/// P)`, and `l_contour_SKBB` is byte-for-byte identical to `l_contour_UIS`
/// (down to the knot markers Mapiah already omits from both), so both reuse
/// the existing UIS decorator/color instead of a new SKBB class.
///
/// `waterFlow -subtype conjectural` is handled below (a dotted redraw of
/// the shared `l_waterflow_permanent_UIS` meander, see
/// [MPWaterFlowConjecturalSKBBLineDecorator]); `permanent`/no-subtype
/// falls through to that same UIS decorator unchanged.
///
/// Every other SKBB-owned line type this map doesn't cover — wall subtype
/// lines (already rendered set-neutrally via dash-pattern `THLinePaint`,
/// not this decorator pipeline), `border` visible/temporary/presumed,
/// `survey` surface, `waterFlow` intermittent, `arrow`, `mapConnection`,
/// `section`, and the `rope`/`steps`/`handrail`/`fixedLadder`/
/// `ropeLadder`/`viaFerrata`/`slope` *line* types (as opposed to the point
/// types of the same name, which Phase 4B does implement) — falls back to
/// UIS/placeholder until a follow-up phase.
final Map<THLineType, MPTherionLineDefinition> _skbbLineDefinitions = {
  THLineType.chimney: MPTherionLineDefinition(
    decorator: const MPChimneyLineDecorator(),
    color: mpTherionLineColors[THLineType.chimney]!,
  ),
  THLineType.contour: MPTherionLineDefinition(
    decorator: const MPContourLineDecorator(),
    color: mpTherionLineColors[THLineType.contour]!,
  ),
  THLineType.ceilingStep: MPTherionLineDefinition(
    decorator: const MPCeilingStepSKBBLineDecorator(),
    color: mpTherionLineColors[THLineType.ceilingStep]!,
  ),
  THLineType.ceilingMeander: MPTherionLineDefinition(
    decorator: const MPCeilingMeanderSKBBLineDecorator(),
    color: mpTherionLineColors[THLineType.ceilingMeander]!,
  ),
  THLineType.floorMeander: MPTherionLineDefinition(
    decorator: const MPFloorMeanderSKBBLineDecorator(),
    color: THPaint.thPaint5,
  ),
  THLineType.overhang: MPTherionLineDefinition(
    decorator: const MPOverhangSKBBLineDecorator(),
    color: THPaint.thPaint10,
  ),
};

/// Resolves the SKBB-specific line decorator/color for [lineType]/[subtype].
/// Returns null for every line type/subtype not covered above, letting the
/// caller fall back to UIS.
MPTherionLineDefinition? getTherionSKBBLineDefinition({
  required THLineType lineType,
  String? subtype,
}) {
  if ((lineType == THLineType.waterFlow) && (subtype == 'conjectural')) {
    final MPLineDecorator decorator =
        const MPWaterFlowConjecturalSKBBLineDecorator();
    final color = mpTherionLineColors[THLineType.waterFlow];

    if (color == null) {
      return null;
    }

    return MPTherionLineDefinition(decorator: decorator, color: color);
  }

  return _skbbLineDefinitions[lineType];
}
