// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
abstract class THLinePainterLineSegment {
  double x;
  double y;

  /// Raw `l-size`/`orientation` line point option values, straight from the
  /// underlying [THLineSegment] with no defaulting applied — null when the
  /// option isn't set on this point. Used by `THLineType.slope`'s SKBB
  /// decorator ([MPLineSlopeSKBBLineDecorator]) to port `l_slope_SKBB`'s
  /// per-point width/direction; ignored by every other decorator.
  final double? lSize;
  final double? orientation;

  THLinePainterLineSegment({
    required this.x,
    required this.y,
    this.lSize,
    this.orientation,
  });
}

class THLinePainterStraightLineSegment extends THLinePainterLineSegment {
  THLinePainterStraightLineSegment({
    required super.x,
    required super.y,
    super.lSize,
    super.orientation,
  });
}

class THLinePainterBezierCurveLineSegment extends THLinePainterLineSegment {
  double controlPoint1X;
  double controlPoint1Y;
  double controlPoint2X;
  double controlPoint2Y;

  THLinePainterBezierCurveLineSegment({
    required super.x,
    required super.y,
    required this.controlPoint1X,
    required this.controlPoint1Y,
    required this.controlPoint2X,
    required this.controlPoint2Y,
    super.lSize,
    super.orientation,
  });
}
