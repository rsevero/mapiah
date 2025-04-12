import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THLineSegmentPainter extends CustomPainter {
  final THLineSegment previousLineSegment;
  final THLineSegment lineSegment;
  final Paint linePaintStroke;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  THLineSegmentPainter({
    super.repaint,
    required this.previousLineSegment,
    required this.lineSegment,
    required this.linePaintStroke,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();

    path.moveTo(previousLineSegment.x, previousLineSegment.y);

    switch (lineSegment) {
      case THBezierCurveLineSegment _:
        path.cubicTo(
          (lineSegment as THBezierCurveLineSegment).controlPoint1X,
          (lineSegment as THBezierCurveLineSegment).controlPoint1Y,
          (lineSegment as THBezierCurveLineSegment).controlPoint2X,
          (lineSegment as THBezierCurveLineSegment).controlPoint2Y,
          lineSegment.x,
          lineSegment.y,
        );
      case THLinePainterStraightLineSegment _:
        path.lineTo(lineSegment.x, lineSegment.y);
    }

    canvas.drawPath(path, linePaintStroke);
  }

  @override
  bool shouldRepaint(covariant THLineSegmentPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return linePaintStroke != oldDelegate.linePaintStroke ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation ||
        lineSegment != oldDelegate.lineSegment ||
        previousLineSegment != oldDelegate.previousLineSegment;
  }
}
