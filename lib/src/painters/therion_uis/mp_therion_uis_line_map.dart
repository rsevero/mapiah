// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/painters/helpers/mp_line_decorator.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_line_definition.dart';
import 'package:mapiah/src/painters/therion_uis/mp_ceiling_meander_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_ceiling_step_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_chimney_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_contour_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_flowstone_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_gradient_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_moonmilk_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_pit_floor_step_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_rock_edge_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_survey_cave_line_decorator.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_line_paints.dart';
import 'package:mapiah/src/painters/therion_uis/mp_water_flow_permanent_line_decorator.dart';

/// Resolves the Therion UIS line decorator/color for a [THLineType] and
/// subtype, transcribed unchanged from the pre-Phase-4
/// `MPVisualControllerBase.getLineDecorator` switch. This is the UIS
/// baseline that the set-aware line registry falls back to.
MPTherionLineDefinition? getTherionUISLineDefinition({
  required THLineType lineType,
  String? subtype,
}) {
  final MPLineDecorator? decorator = switch (lineType) {
    THLineType.ceilingMeander => const MPCeilingMeanderLineDecorator(),
    THLineType.ceilingStep => const MPCeilingStepLineDecorator(),
    THLineType.chimney => const MPChimneyLineDecorator(),
    THLineType.contour => const MPContourLineDecorator(),
    THLineType.floorStep ||
    THLineType.pit ||
    THLineType.pitch => const MPPitFloorStepLineDecorator(),
    THLineType.flowstone => const MPFlowstoneLineDecorator(),
    THLineType.gradient => const MPGradientLineDecorator(),
    THLineType.moonmilk => const MPMoonmilkLineDecorator(),
    THLineType.rockEdge => const MPRockEdgeLineDecorator(),
    THLineType.survey when (subtype == null) || (subtype == 'cave') =>
      const MPSurveyCaveLineDecorator(),
    THLineType.waterFlow when (subtype == null) || (subtype == 'permanent') =>
      const MPWaterFlowPermanentLineDecorator(),
    _ => null,
  };

  if (decorator == null) {
    return null;
  }

  final color = mpTherionLineColors[lineType];

  if (color == null) {
    return null;
  }

  return MPTherionLineDefinition(decorator: decorator, color: color);
}
