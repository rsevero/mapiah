// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/painters/types/mp_line_paint_type.dart';

class THLinePaint {
  final Paint? primaryPaint;
  final Paint? secondaryPaint;
  final Paint? fillPaint;
  final List<Paint> highlightBorders;
  final MPLinePaintType type;

  /// True for Therion area patterns whose `.mp` macro calls `thclean`
  /// before filling with the pattern (e.g. `a_water_UIS`), so the erased
  /// background shows through gaps in the pattern instead of whatever was
  /// drawn underneath.
  final bool cleanBeforeFill;

  THLinePaint({
    this.primaryPaint,
    this.secondaryPaint,
    this.fillPaint,
    this.highlightBorders = const [],
    this.type = MPLinePaintType.continuous,
    this.cleanBeforeFill = false,
  });

  THLinePaint copyWith({
    Paint? primaryPaint,
    bool makePrimaryPaintNull = false,
    Paint? secondaryPaint,
    bool makeSecondaryPaintNull = false,
    Paint? fillPaint,
    bool makeFillPaintNull = false,
    List<Paint>? highlightBorders,
    MPLinePaintType? type,
    bool? cleanBeforeFill,
  }) {
    return THLinePaint(
      primaryPaint: makePrimaryPaintNull
          ? null
          : (primaryPaint ?? this.primaryPaint),
      secondaryPaint: makeSecondaryPaintNull
          ? null
          : (secondaryPaint ?? this.secondaryPaint),
      fillPaint: makeFillPaintNull ? null : (fillPaint ?? this.fillPaint),
      highlightBorders: highlightBorders ?? this.highlightBorders,
      type: type ?? this.type,
      cleanBeforeFill: cleanBeforeFill ?? this.cleanBeforeFill,
    );
  }
}
