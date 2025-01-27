import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

class THLinePainter extends CustomPainter {
  final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap;
  final Paint linePaint;
  final TH2FileEditStore th2FileEditStore;

  THLinePainter({
    super.repaint,
    required this.lineSegmentsMap,
    required this.linePaint,
    required this.th2FileEditStore,
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
          break;
        case THLinePainterStraightLineSegment _:
          path.lineTo(lineSegment.x, lineSegment.y);
          break;
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant THLinePainter oldDelegate) {
    return true;
  }
}
