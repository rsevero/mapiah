import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';

class THLinePainter extends CustomPainter {
  final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap;
  final Paint linePaint;
  final THFileDisplayStore thFileDisplayStore;

  THLinePainter({
    super.repaint,
    required this.lineSegmentsMap,
    required this.linePaint,
    required this.thFileDisplayStore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Iterable<THLinePainterLineSegment> lineSegments =
        lineSegmentsMap.values;
    bool isFirst = true;
    final Path path = Path();

    thFileDisplayStore.transformCanvas(canvas);

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
    if (linePaint != oldDelegate.linePaint) {
      return true;
    }

    final MapEquality<int, THLinePainterLineSegment> mapEquality =
        MapEquality<int, THLinePainterLineSegment>();

    if (!mapEquality.equals(lineSegmentsMap, oldDelegate.lineSegmentsMap)) {
      return true;
    }

    return false;
  }
}