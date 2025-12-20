import 'package:flutter/material.dart';
import 'package:mapiah/src/painters/types/mp_line_paint_type.dart';

class THLinePaint {
  final Paint? primaryPaint;
  final Paint? secondaryPaint;
  final Paint? fillPaint;
  final List<Paint> highlightBorders;
  final MPLinePaintType type;

  THLinePaint({
    this.primaryPaint,
    this.secondaryPaint,
    this.fillPaint,
    this.highlightBorders = const [],
    this.type = MPLinePaintType.continuous,
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
    );
  }
}
