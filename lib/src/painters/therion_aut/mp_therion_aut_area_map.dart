// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui' as ui;

import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/painters/therion_aut/mp_therion_area_pattern_tiles_aut.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_area_pattern_definition.dart';

/// One entry per [THAreaType] with a Phase 4C Therion AUT pattern tile.
/// Colors are borrowed from each area type's placeholder paint
/// (`mp_visual_controller.dart`'s `areaTypePaints`), matching the
/// convention `mpTherionSKBBAreaPatternColors` already uses.
final Map<THAreaType, ui.Image Function(ui.Color)> _tileBuilders = {
  THAreaType.water: MPTherionAreaPatternTilesAUT.buildWaterTile,
  THAreaType.sump: MPTherionAreaPatternTilesAUT.buildSumpTile,
  THAreaType.sand: MPTherionAreaPatternTilesAUT.buildSandTile,
  THAreaType.clay: MPTherionAreaPatternTilesAUT.buildSandTile,
  THAreaType.pebbles: MPTherionAreaPatternTilesAUT.buildPebblesTile,
  THAreaType.debris: MPTherionAreaPatternTilesAUT.buildDebrisTile,
  THAreaType.ice: MPTherionAreaPatternTilesAUT.buildIceTile,
  THAreaType.snow: MPTherionAreaPatternTilesAUT.buildSnowTile,
  THAreaType.blocks: MPTherionAreaPatternTilesAUT.buildBlocksTile,
  THAreaType.flowstone: MPTherionAreaPatternTilesAUT.buildFlowstoneTile,
};

final Map<THAreaType, ui.Color> mpTherionAUTAreaPatternColors = {
  THAreaType.water: THPaint.thPaint3.color,
  THAreaType.sump: THPaint.thPaint14.color,
  THAreaType.sand: THPaint.thPaint13.color,
  THAreaType.clay: THPaint.thPaint13.color,
  THAreaType.pebbles: THPaint.thPaint5.color,
  THAreaType.debris: THPaint.thPaint12.color,
  THAreaType.ice: THPaint.thPaint9.color,
  THAreaType.snow: THPaint.thPaint7.color,
  THAreaType.blocks: THPaint.thPaint12.color,
  THAreaType.flowstone: THPaint.thPaint6.color,
};

/// Resolves the AUT-specific area pattern tile definition for [areaType].
/// Returns null for every area type AUT doesn't define its own tile for,
/// letting the caller ([getTherionAreaPatternDefinition]) fall through to
/// `thTrans.mp`'s own default set for this area type, and only then to
/// UIS.
MPTherionAreaPatternDefinition? getTherionAUTAreaPatternDefinition(
  THAreaType areaType,
) {
  final ui.Image Function(ui.Color)? tileBuilder = _tileBuilders[areaType];
  final ui.Color? color = mpTherionAUTAreaPatternColors[areaType];

  if (tileBuilder == null || color == null) {
    return null;
  }

  return MPTherionAreaPatternDefinition(
    tileBuilder: tileBuilder,
    color: color,
    cleanBeforeFill: true,
  );
}
