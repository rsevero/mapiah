// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui' as ui;

import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_area_pattern_definition.dart';
import 'package:mapiah/src/painters/therion_uis/mp_area_pattern_tiles.dart';
import 'package:mapiah/src/painters/therion_uis/mp_therion_area_paints.dart';

/// Area types whose Therion UIS pattern tile must not be preceded by a
/// [MPThClean] pass, transcribed unchanged from the pre-Phase-4
/// `MPVisualControllerBase.getDefaultAreaPaint` condition
/// `(areaType != THAreaType.debris) && (areaType != THAreaType.sand)`.
const Set<THAreaType> _uisAreaPatternSkipClean = <THAreaType>{
  THAreaType.debris,
  THAreaType.sand,
};

/// Resolves the Therion UIS area pattern tile builder/color for a
/// [THAreaType], transcribed unchanged from the pre-Phase-4
/// `MPVisualControllerBase._getTherionUISAreaPatternPaint` switch. This is
/// the UIS baseline that the set-aware area pattern registry falls back to.
MPTherionAreaPatternDefinition? getTherionUISAreaPatternDefinition(
  THAreaType areaType,
) {
  final ui.Color? color = mpTherionAreaPatternColors[areaType];

  if (color == null) {
    return null;
  }

  final ui.Image Function(ui.Color) tileBuilder = switch (areaType) {
    THAreaType.water => MPTherionAreaPatternTilesUIS.buildWaterTile,
    THAreaType.sump => MPTherionAreaPatternTilesUIS.buildSumpTile,
    THAreaType.debris => MPTherionAreaPatternTilesUIS.buildDebrisTile,
    THAreaType.flowstone => MPTherionAreaPatternTilesUIS.buildFlowstoneTile,
    THAreaType.moonmilk => MPTherionAreaPatternTilesUIS.buildMoonmilkTile,
    THAreaType.sand => MPTherionAreaPatternTilesUIS.buildSandTile,
    _ => throw StateError(
      'mpTherionAreaPatternColors has an entry for $areaType with no '
      'matching tile builder',
    ),
  };

  return MPTherionAreaPatternDefinition(
    tileBuilder: tileBuilder,
    color: color,
    cleanBeforeFill: !_uisAreaPatternSkipClean.contains(areaType),
  );
}
