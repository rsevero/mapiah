import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/aux/th_line_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THLineSegmentPainter extends CustomPainter {
  final THLineSegment previousLineSegment;
  final THLineSegment lineSegment;
  final THLinePaint linePaint;
  final TH2FileEditController th2FileEditController;

  THLineSegmentPainter({
    super.repaint,
    required this.previousLineSegment,
    required this.lineSegment,
    required this.linePaint,
    required this.th2FileEditController,
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

    if (linePaint.fillPaint != null) {
      canvas.drawPath(path, linePaint.fillPaint!);
    }
    if (linePaint.secondaryPaint != null) {
      canvas.drawPath(path, linePaint.secondaryPaint!);
    }
    if (linePaint.primaryPaint != null) {
      canvas.drawPath(path, linePaint.primaryPaint!);
    }
  }

  @override
  bool shouldRepaint(covariant THLineSegmentPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return linePaint != oldDelegate.linePaint ||
        lineSegment != oldDelegate.lineSegment ||
        previousLineSegment != oldDelegate.previousLineSegment;
  }
}
