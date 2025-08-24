import 'package:flutter/material.dart';
import 'package:mapiah/src/painters/types/mp_line_paint_type.dart';

class THLinePaint {
  final Paint? primaryPaint;
  final Paint? secondaryPaint;
  final Paint? fillPaint;
  final MPLinePaintType type;

  THLinePaint({
    this.primaryPaint,
    this.secondaryPaint,
    this.fillPaint,
    this.type = MPLinePaintType.continuous,
  });

  THLinePaint copyWith({
    Paint? primaryPaint,
    Paint? secondaryPaint,
    Paint? fillPaint,
    MPLinePaintType? type,
    bool makePrimaryPaintNull = false,
    bool makeSecondaryPaintNull = false,
    bool makeFillPaintNull = false,
  }) {
    return THLinePaint(
      primaryPaint: makePrimaryPaintNull
          ? null
          : (primaryPaint ?? this.primaryPaint),
      secondaryPaint: makeSecondaryPaintNull
          ? null
          : (secondaryPaint ?? this.secondaryPaint),
      fillPaint: makeFillPaintNull ? null : (fillPaint ?? this.fillPaint),
      type: type ?? this.type,
    );
  }
}
