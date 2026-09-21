// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_flowstone_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_pit_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_survey_cave_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_blocks_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_debris_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_flowstone_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_ice_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_moonmilk_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_overlying_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_pebbles_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_pit_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_sand_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_aut/mp_wall_underlying_aut_line_decorator.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_line_definition.dart';
import 'package:mapiah/src/painters/therion_uis/mp_ceiling_meander_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_ceiling_step_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_contour_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_pit_floor_step_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_line_paints.dart';

/// Phase 4C Therion AUT line decorators.
///
/// `pit` and `overhang` both resolve to [MPPitAUTLineDecorator]:
/// `l_overhang_AUT` is `let`-aliased straight to `l_pit_AUT` in
/// `uAUT.mp`, so they share both the macro and (matching real Therion,
/// which has no separate color for the alias) `pit`'s own color.
///
/// `floorStep` aliases `l_floorstep_UIS`, `contour` aliases
/// `l_contour_SKBB` (itself byte-for-byte identical to `l_contour_UIS`),
/// and `ceilingStep`/`ceilingMeander` alias their `_UIS` macros — all four
/// `let`-assignments in `uAUT.mp` itself, so they reuse the already-ported
/// decorator/color instead of duplicating the geometry.
///
/// `flowstone` (the standalone line type) is
/// [MPFlowstoneAUTLineDecorator]; `survey -subtype cave` is
/// [MPSurveyCaveAUTLineDecorator] (AUT's own `l_survey_cave_AUT`, used
/// only when `symbol-set AUT` is explicitly selected — `thTrans.mp`'s own
/// default for `survey` is always SKBB, see
/// `mp_therion_default_symbol_set.dart`).
///
/// `wall -subtype pit`/`sand`/`pebbles`/`clay`/`debris`/`blocks`/`ice`/
/// `underlying`/`overlying`/`moonmilk`/`flowstone` are handled below, each
/// porting its own `l_wall_*_AUT` macro (`clay` a bare `let` alias of
/// `sand`). Every other `wall` subtype has no AUT-specific macro and keeps
/// falling back through `thTrans.mp`'s own default (SKBB/UIS) or, failing
/// that, Mapiah's placeholder.
final Map<THLineType, MPTherionLineDefinition> _autLineDefinitions = {
  THLineType.pit: MPTherionLineDefinition(
    decorator: const MPPitAUTLineDecorator(),
    color: mpTherionLineColors[THLineType.pit]!,
  ),
  THLineType.overhang: MPTherionLineDefinition(
    decorator: const MPPitAUTLineDecorator(),
    color: mpTherionLineColors[THLineType.pit]!,
  ),
  THLineType.floorStep: MPTherionLineDefinition(
    decorator: const MPPitFloorStepLineDecorator(),
    color: mpTherionLineColors[THLineType.floorStep]!,
  ),
  THLineType.contour: MPTherionLineDefinition(
    decorator: const MPContourLineDecorator(),
    color: mpTherionLineColors[THLineType.contour]!,
  ),
  THLineType.ceilingStep: MPTherionLineDefinition(
    decorator: const MPCeilingStepLineDecorator(),
    color: mpTherionLineColors[THLineType.ceilingStep]!,
  ),
  THLineType.ceilingMeander: MPTherionLineDefinition(
    decorator: const MPCeilingMeanderLineDecorator(),
    color: mpTherionLineColors[THLineType.ceilingMeander]!,
  ),
  THLineType.flowstone: MPTherionLineDefinition(
    decorator: const MPFlowstoneAUTLineDecorator(),
    color: mpTherionLineColors[THLineType.flowstone]!,
  ),
};

/// Resolves the AUT-specific line decorator/color for [lineType]/[subtype].
/// Returns null for every line type/subtype not covered above, letting the
/// caller ([getTherionLineDefinition]) fall through to `thTrans.mp`'s own
/// default set for this line type/subtype, and only then to UIS.
MPTherionLineDefinition? getTherionAUTLineDefinition({
  required THLineType lineType,
  String? subtype,
}) {
  final MPLineDecorator? subtypeDecorator = switch (lineType) {
    THLineType.wall => switch (subtype) {
      'pit' => const MPWallPitAUTLineDecorator(),
      'sand' || 'clay' => const MPWallSandAUTLineDecorator(),
      'pebbles' => const MPWallPebblesAUTLineDecorator(),
      'debris' => const MPWallDebrisAUTLineDecorator(),
      'blocks' => const MPWallBlocksAUTLineDecorator(),
      'ice' => const MPWallIceAUTLineDecorator(),
      'underlying' => const MPWallUnderlyingAUTLineDecorator(),
      'overlying' => const MPWallOverlyingAUTLineDecorator(),
      'moonmilk' => const MPWallMoonmilkAUTLineDecorator(),
      'flowstone' => const MPWallFlowstoneAUTLineDecorator(),
      _ => null,
    },
    THLineType.survey => switch (subtype) {
      null || 'cave' => const MPSurveyCaveAUTLineDecorator(),
      _ => null,
    },
    _ => null,
  };

  if (subtypeDecorator != null) {
    final color = mpTherionLineColors[lineType];

    if (color == null) {
      return null;
    }

    return MPTherionLineDefinition(decorator: subtypeDecorator, color: color);
  }

  return _autLineDefinitions[lineType];
}
