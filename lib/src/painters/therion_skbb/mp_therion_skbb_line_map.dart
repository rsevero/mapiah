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
import 'package:mapiah/src/painters/therion_skbb/mp_rope_ladder_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_survey_cave_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_survey_surface_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_via_ferrata_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_blocks_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_clay_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_debris_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_ice_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_pebbles_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_sand_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_wall_unsurveyed_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_water_flow_conjectural_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_water_flow_intermittent_skbb_line_decorator.dart';
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
/// `waterFlow -subtype conjectural`/`intermittent` are handled below (a
/// dotted/dashed redraw of the shared `l_waterflow_permanent_UIS` meander,
/// see [MPWaterFlowConjecturalSKBBLineDecorator]/
/// [MPWaterFlowIntermittentSKBBLineDecorator]); `permanent`/no-subtype
/// falls through to that same UIS decorator unchanged.
///
/// `wall -subtype sand`/`pebbles`/`clay`/`debris`/`blocks`/`ice`/
/// `unsurveyed` are also handled below, each porting its own
/// `l_wall_*_SKBB` macro. Every other `wall` subtype (`bedrock`,
/// `underlying`, `presumed`, and any without a dedicated SKBB macro at
/// all) has no SKBB-specific rendering in Therion itself and keeps
/// falling back to Mapiah's placeholder dash-pattern `THLinePaint`
/// (`wallSubtypesPaints`), same as before.
///
/// `ropeLadder`/`viaFerrata` are also handled below, porting
/// `l_ropeladder_SKBB`/`l_viaferrata_SKBB` — both currently stubs in
/// Therion itself (a plain red line, the same "unimplemented" pattern as
/// `l_u`), so [MPRopeLadderSKBBLineDecorator]/[MPViaFerrataSKBBLineDecorator]
/// port that literally rather than inventing a real symbol Therion
/// doesn't have yet.
///
/// `survey -subtype cave`/no-subtype and `-subtype surface` are also
/// handled below, porting `l_survey_cave_SKBB`/`l_survey_surface_SKBB` —
/// notably, Therion aliases the set-neutral `l_survey_cave`/
/// `l_survey_surface` straight to these SKBB definitions in
/// `thTrans.mp` (there's no `l_survey_surface_UIS` at all), so these are
/// what a real Therion run renders under any symbol set, not something
/// SKBB-specific being invented here.
///
/// Every other SKBB-owned line type this map doesn't cover — `border`
/// visible/temporary/presumed, `arrow`, `mapConnection`, `section`, and
/// the `rope`/`steps`/`handrail`/`fixedLadder`/`slope` *line* types (as
/// opposed to the point types of the same name, which Phase 4B does
/// implement) — is `thTrans.mp`'s default here too (see
/// `mp_therion_default_symbol_set.dart`), but since neither this map nor
/// UIS has a decorator for it yet, [getTherionLineDefinition] still ends
/// up at the Mapiah placeholder until a follow-up phase ports it.
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
  THLineType.ropeLadder: MPTherionLineDefinition(
    decorator: const MPRopeLadderSKBBLineDecorator(),
    color: mpTherionLineColors[THLineType.ropeLadder]!,
  ),
  THLineType.viaFerrata: MPTherionLineDefinition(
    decorator: const MPViaFerrataSKBBLineDecorator(),
    color: mpTherionLineColors[THLineType.viaFerrata]!,
  ),
};

/// Resolves the SKBB-specific line decorator/color for [lineType]/[subtype].
/// Returns null for every line type/subtype not covered above, letting the
/// caller ([getTherionLineDefinition]) fall through to `thTrans.mp`'s own
/// default set for this line type/subtype, and only then to UIS.
MPTherionLineDefinition? getTherionSKBBLineDefinition({
  required THLineType lineType,
  String? subtype,
}) {
  final MPLineDecorator? subtypeDecorator = switch (lineType) {
    THLineType.waterFlow => switch (subtype) {
      'conjectural' => const MPWaterFlowConjecturalSKBBLineDecorator(),
      'intermittent' => const MPWaterFlowIntermittentSKBBLineDecorator(),
      _ => null,
    },
    THLineType.wall => switch (subtype) {
      'sand' => const MPWallSandSKBBLineDecorator(),
      'pebbles' => const MPWallPebblesSKBBLineDecorator(),
      'clay' => const MPWallClaySKBBLineDecorator(),
      'debris' => const MPWallDebrisSKBBLineDecorator(),
      'blocks' => const MPWallBlocksSKBBLineDecorator(),
      'ice' => const MPWallIceSKBBLineDecorator(),
      'unsurveyed' => const MPWallUnsurveyedSKBBLineDecorator(),
      _ => null,
    },
    THLineType.survey => switch (subtype) {
      null || 'cave' => const MPSurveyCaveSKBBLineDecorator(),
      'surface' => const MPSurveySurfaceSKBBLineDecorator(),
      _ => null,
    },
    _ => null,
  };

  if (subtypeDecorator != null) {
    final color = mpTherionLineColors[lineType];

    if (color == null) {
      return null;
    }

    return MPTherionLineDefinition(
      decorator: subtypeDecorator,
      color: color,
    );
  }

  return _skbbLineDefinitions[lineType];
}
