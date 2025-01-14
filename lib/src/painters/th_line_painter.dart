import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';

class THLinePainter extends CustomPainter {
  final THLine line;
  final Paint linePaint;
  final THFile thFile;
  final THFileDisplayStore thFileDisplayStore;

  THLinePainter({
    super.repaint,
    required this.line,
    required this.linePaint,
    required this.thFileDisplayStore,
  }) : thFile = line.thFile;

  @override
  void paint(Canvas canvas, Size size) {
    thFileDisplayStore.transformCanvas(canvas);

    final List<int> lineSegmentMapiahIDs = line.childrenMapiahID;
    bool isFirst = true;
    final Path path = Path();

    for (int lineSegmentMapiahID in lineSegmentMapiahIDs) {
      final THElement lineSegment =
          thFile.elementByMapiahID(lineSegmentMapiahID);

      if (lineSegment is! THLineSegment) {
        continue;
      }

      if (isFirst) {
        path.moveTo(lineSegment.x, lineSegment.y);
        isFirst = false;
        continue;
      }

      switch (lineSegment) {
        case THBezierCurveLineSegment _:
          path.cubicTo(
            lineSegment.controlPoint1X,
            lineSegment.controlPoint1Y,
            lineSegment.controlPoint2X,
            lineSegment.controlPoint2Y,
            lineSegment.x,
            lineSegment.y,
          );
          break;
        case THStraightLineSegment _:
          path.lineTo(lineSegment.x, lineSegment.y);
          break;
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant THLinePainter oldDelegate) {
    if ((linePaint != oldDelegate.linePaint) ||
        (line.childrenMapiahID.length !=
            oldDelegate.line.childrenMapiahID.length) ||
        (line.thFile != oldDelegate.thFile)) {
      return true;
    }

    final ListEquality<int> listEquality = ListEquality<int>();

    if (!listEquality.equals(
        line.childrenMapiahID, oldDelegate.line.childrenMapiahID)) {
      return true;
    }

    return false;
  }
}
