// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui' as ui;

import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/painters/therion_common/mp_therion_area_pattern_definition.dart';
import 'package:mapiah/src/painters/therion_skbb/mp_therion_area_pattern_tiles_skbb.dart';

/// One entry per [THAreaType] with a Phase 4B Therion SKBB pattern tile.
/// Colors are borrowed from each area type's placeholder paint
/// (`mp_visual_controller.dart`'s `areaTypePaints`), matching the
/// convention `mpTherionAreaPatternColors` already uses for UIS.
/// `THAreaType.bedrock` is intentionally absent: `a_bedrock_SKBB` is a bare
/// `thclean`, i.e. the plain unpatterned fill Mapiah already renders.
final Map<THAreaType, ui.Image Function(ui.Color)> _tileBuilders = {
  THAreaType.water: MPTherionAreaPatternTilesSKBB.buildWaterTile,
  THAreaType.sump: MPTherionAreaPatternTilesSKBB.buildSumpTile,
  THAreaType.clay: MPTherionAreaPatternTilesSKBB.buildClayTile,
  THAreaType.ice: MPTherionAreaPatternTilesSKBB.buildIceTile,
  THAreaType.snow: MPTherionAreaPatternTilesSKBB.buildSnowTile,
  THAreaType.blocks: MPTherionAreaPatternTilesSKBB.buildBlocksTile,
  THAreaType.pebbles: MPTherionAreaPatternTilesSKBB.buildPebblesTile,
  THAreaType.debris: MPTherionAreaPatternTilesSKBB.buildDebrisTile,
};

final Map<THAreaType, ui.Color> mpTherionSKBBAreaPatternColors = {
  THAreaType.water: THPaint.thPaint3.color,
  THAreaType.sump: THPaint.thPaint14.color,
  THAreaType.clay: THPaint.thPaint10.color,
  THAreaType.ice: THPaint.thPaint9.color,
  THAreaType.snow: THPaint.thPaint7.color,
  THAreaType.blocks: THPaint.thPaint12.color,
  THAreaType.pebbles: THPaint.thPaint5.color,
  THAreaType.debris: THPaint.thPaint12.color,
};

/// Resolves the SKBB-specific area pattern tile definition for [areaType].
/// Returns null for every area type SKBB doesn't define its own tile for
/// (including `bedrock`, which is deliberately unpatterned), letting the
/// caller fall back to UIS.
MPTherionAreaPatternDefinition? getTherionSKBBAreaPatternDefinition(
  THAreaType areaType,
) {
  final ui.Image Function(ui.Color)? tileBuilder = _tileBuilders[areaType];
  final ui.Color? color = mpTherionSKBBAreaPatternColors[areaType];

  if (tileBuilder == null || color == null) {
    return null;
  }

  return MPTherionAreaPatternDefinition(
    tileBuilder: tileBuilder,
    color: color,
    cleanBeforeFill: true,
  );
}
