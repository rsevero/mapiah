// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/mp_label_paint.dart';
import 'package:mapiah/src/painters/types/mp_point_shape_type.dart';
import 'package:mapiah/src/painters/types/mp_therion_point_symbol.dart';

class THPointPaint {
  final double radius;
  final double rotation;
  final MPPointShapeType type;
  final Paint? border;
  final Paint? fill;
  final List<Paint> highlightBorders;

  /// Non-null when the Therion visualization method should draw a faithful
  /// symbol instead of [type]'s abstract placeholder shape.
  final MPTherionPointSymbol? therionSymbol;

  /// Non-null when the Therion visualization method should draw a text
  /// label (Phase 2.5) instead of [type]'s abstract placeholder shape.
  /// Mutually exclusive with [therionSymbol].
  final MPLabelPaint? labelPaint;

  THPointPaint({
    this.radius = mpDefaultPointRadius,
    this.rotation = 0,
    this.type = MPPointShapeType.circle,
    this.border,
    this.fill,
    this.highlightBorders = const [],
    this.therionSymbol,
    this.labelPaint,
  }) : assert(radius > 0, "Radius must be greater than 0"),
       assert(
         (border != null) || (fill != null),
         "At least one of border or fill must be provided",
       );

  THPointPaint copyWith({
    double? radius,
    double? rotation,
    MPPointShapeType? type,
    Paint? border,
    bool makeBorderPaintNull = false,
    Paint? fill,
    bool makeFillPaintNull = false,
    List<Paint>? highlightBorders,
    MPTherionPointSymbol? therionSymbol,
    bool makeTherionSymbolNull = false,
    MPLabelPaint? labelPaint,
    bool makeLabelPaintNull = false,
  }) {
    return THPointPaint(
      radius: radius ?? this.radius,
      rotation: rotation ?? this.rotation,
      type: type ?? this.type,
      border: makeBorderPaintNull ? null : (border ?? this.border),
      fill: makeFillPaintNull ? null : (fill ?? this.fill),
      highlightBorders: highlightBorders ?? this.highlightBorders,
      therionSymbol: makeTherionSymbolNull
          ? null
          : (therionSymbol ?? this.therionSymbol),
      labelPaint: makeLabelPaintNull ? null : (labelPaint ?? this.labelPaint),
    );
  }
}
