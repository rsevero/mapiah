import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THLinePainter extends CustomPainter {
  final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap;
  final Paint linePaintStroke;
  final Paint? linePaintFill;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  THLinePainter({
    super.repaint,
    required this.lineSegmentsMap,
    required this.linePaintStroke,
    this.linePaintFill,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Iterable<THLinePainterLineSegment> lineSegments =
        lineSegmentsMap.values;
    bool isFirst = true;
    final Path path = Path();

    for (THLinePainterLineSegment lineSegment in lineSegments) {
      if (isFirst) {
        path.moveTo(lineSegment.x, lineSegment.y);
        isFirst = false;
        continue;
      }

      switch (lineSegment) {
        case THLinePainterBezierCurveLineSegment _:
          path.cubicTo(
            lineSegment.controlPoint1X,
            lineSegment.controlPoint1Y,
            lineSegment.controlPoint2X,
            lineSegment.controlPoint2Y,
            lineSegment.x,
            lineSegment.y,
          );
        case THLinePainterStraightLineSegment _:
          path.lineTo(lineSegment.x, lineSegment.y);
      }
    }
    if (linePaintFill != null) {
      canvas.drawPath(path, linePaintFill!);
    }
    canvas.drawPath(path, linePaintStroke);
  }

  @override
  bool shouldRepaint(covariant THLinePainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return linePaintStroke != oldDelegate.linePaintStroke ||
        linePaintFill != oldDelegate.linePaintFill ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation ||
        !const MapEquality<int, THLinePainterLineSegment>()
            .equals(lineSegmentsMap, oldDelegate.lineSegmentsMap);
  }
}
