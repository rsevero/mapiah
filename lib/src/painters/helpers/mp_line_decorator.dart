// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:ui';

import 'package:mapiah/src/painters/helpers/mp_symbol_unit.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

/// Draws a Therion line representation along an already built geometry path.
abstract class MPLineDecorator {
  const MPLineDecorator();

  /// Returns the geometry path that should be passed to [decorate].
  Path buildBasePath({
    required Path path,
    required List<Offset> vertices,
    required MPSymbolUnit symbolUnit,
  }) {
    return path;
  }

  /// [color] is the decorator's own paint (`mpTherionLineColors`),
  /// independent of the `THLinePaint` used by Mapiah's placeholder line
  /// renderer. [mpID] seeds procedural randomness (e.g.
  /// `l_waterflow_permanent_UIS`'s meander noise) so a given element's
  /// decoration is stable across repaints; defaults to 0 for decorators
  /// that don't need it. [lineSegments] carries the ordered vertices behind
  /// [path], each with its raw (undefaulted) `l-size`/`orientation` line
  /// point options — only the SKBB `slope` line decorator (`l_slope_SKBB`)
  /// reads it; every other decorator ignores it. [showBorder] mirrors
  /// `line slope -border on` (`l_slope_SKBB`'s baseline stroke); every
  /// other decorator ignores it too.
  void decorate({
    required Canvas canvas,
    required Path path,
    required Paint color,
    required MPSymbolUnit symbolUnit,
    required bool isReversed,
    int mpID = 0,
    List<THLinePainterLineSegment>? lineSegments,
    bool showBorder = false,
  });
}
