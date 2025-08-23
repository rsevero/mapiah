abstract class THLinePainterLineSegment {
  double x;
  double y;

  THLinePainterLineSegment({required this.x, required this.y});
}

class THLinePainterStraightLineSegment extends THLinePainterLineSegment {
  THLinePainterStraightLineSegment({required super.x, required super.y});
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
  });
}
