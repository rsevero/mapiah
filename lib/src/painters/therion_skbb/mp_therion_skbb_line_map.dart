// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_line_definition.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_arrow_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_border_presumed_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_border_temporary_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_ceiling_meander_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_ceiling_step_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_chimney_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_fixed_ladder_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_floor_meander_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_handrail_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_line_slope_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_map_connection_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_overhang_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_rope_ladder_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_rope_skbb_line_decorator.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_steps_skbb_line_decorator.dart';
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
import 'package:mapiah/src/painters/therion_uis/mp_contour_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_line_paints.dart';

/// Phase 4B Therion SKBB line decorators.
///
/// `chimney` has its own dedicated `l_chimney_SKBB` macro — a plain,
/// evenly-dashed stroke with no tick marks at all, confirmed against the
/// SKBB showcase's own legend (a plain dashed oval). This is a
/// *different* macro from `l_chimney_UIS` (`l_ceilingstep_SKBB(reverse
/// P)`, tick-marked, still used elsewhere by [MPChimneyLineDecorator]),
/// so, unlike most of this map, [MPChimneySKBBLineDecorator] does *not*
/// reuse the UIS class.
///
/// `l_contour_SKBB` is byte-for-byte identical to `l_contour_UIS` (down
/// to the knot markers Mapiah already omits from both), so that one does
/// reuse the existing UIS decorator/color instead of a new SKBB class.
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
/// `slope` is also handled below, porting `l_slope_SKBB` (a row of
/// perpendicular ticks, alternating full/one-third length, with no stroke
/// of the path itself) — see [MPLineSlopeSKBBLineDecorator].
///
/// `rope`/`steps`/`handrail`/`fixedLadder`/`mapConnection` are also
/// handled below, porting `l_rope_SKBB`/`l_steps_SKBB`/`l_handrail_SKBB`/
/// `l_fixedladder_SKBB`/`l_mapconnection_SKBB` — all five are aliased
/// straight to their SKBB definitions in `thTrans.mp` with no separate
/// UIS macro at all. See each decorator's own doc comment for the
/// specific (documented) scope it doesn't cover — mainly `ATTR__elevation`
/// side views and, for `rope`, the `-anchors`/`-rebelays` line options,
/// none of which this map or [MPLineDecorator] currently has a way to
/// plumb through.
///
/// `border -subtype temporary`/`presumed` and `arrow` are also handled
/// below. `l_border_temporary_SKBB`/`l_border_presumed_SKBB` are both a
/// plain evenly-dashed `PenC` stroke (`presumed` denser than
/// `temporary`), sharing [MPEvenlyDashedSKBBLineDecorator] with
/// `chimney`. `l_arrow_SKBB` is a solid stroke plus a chevron mark
/// gated by the line's `-head` option
/// ([MPCommandOptionAux.getArrowHead]); `border -subtype visible`
/// (`l_border_visible_SKBB`, a plain solid stroke with no dashing at
/// all) isn't ported yet and keeps falling back to the placeholder.
///
/// Every other SKBB-owned line type this map doesn't cover — `section`
/// — is `thTrans.mp`'s default here too (see
/// `mp_therion_default_symbol_set.dart`), but since neither this map nor
/// UIS has a decorator for it yet, [getTherionLineDefinition] still ends
/// up at the Mapiah placeholder until a follow-up phase ports it.
final Map<THLineType, MPTherionLineDefinition> _skbbLineDefinitions = {
  THLineType.chimney: MPTherionLineDefinition(
    decorator: const MPChimneySKBBLineDecorator(),
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
  THLineType.slope: MPTherionLineDefinition(
    decorator: const MPLineSlopeSKBBLineDecorator(),
    color: mpTherionLineColors[THLineType.slope]!,
  ),
  THLineType.rope: MPTherionLineDefinition(
    decorator: const MPRopeSKBBLineDecorator(),
    color: mpTherionLineColors[THLineType.rope]!,
  ),
  THLineType.steps: MPTherionLineDefinition(
    decorator: const MPStepsSKBBLineDecorator(),
    color: mpTherionLineColors[THLineType.steps]!,
  ),
  THLineType.handrail: MPTherionLineDefinition(
    decorator: const MPHandrailSKBBLineDecorator(),
    color: mpTherionLineColors[THLineType.handrail]!,
  ),
  THLineType.fixedLadder: MPTherionLineDefinition(
    decorator: const MPFixedLadderSKBBLineDecorator(),
    color: mpTherionLineColors[THLineType.fixedLadder]!,
  ),
  THLineType.mapConnection: MPTherionLineDefinition(
    decorator: const MPMapConnectionSKBBLineDecorator(),
    color: mpTherionLineColors[THLineType.mapConnection]!,
  ),
  THLineType.arrow: MPTherionLineDefinition(
    decorator: const MPArrowSKBBLineDecorator(),
    color: mpTherionLineColors[THLineType.arrow]!,
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
    THLineType.border => switch (subtype) {
      'temporary' => const MPBorderTemporarySKBBLineDecorator(),
      'presumed' => const MPBorderPresumedSKBBLineDecorator(),
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
