import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_line_segment.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';

class THLineWidget extends StatelessWidget {
  final THLine line;
  final Paint linePaint;
  final THFileDisplayStore thFileDisplayStore;
  final Size screenSize;

  THLineWidget({
    required this.line,
    required this.linePaint,
    required this.thFileDisplayStore,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLinePainterLineSegment>();
    final List<int> lineChildrenMapiahIDs = line.childrenMapiahID;
    final THFile thFile = line.thFile;
    bool isFirst = true;

    for (int lineChildMapiahID in lineChildrenMapiahIDs) {
      final THElement lineChild = thFile.elementByMapiahID(lineChildMapiahID);

      if (lineChild is! THLineSegment) {
        continue;
      }

      if (isFirst) {
        lineSegmentsMap[lineChildMapiahID] = THLinePainterStraightLineSegment(
          x: lineChild.x,
          y: lineChild.y,
        );
        isFirst = false;
        continue;
      }

      switch (lineChild) {
        case THBezierCurveLineSegment _:
          lineSegmentsMap[lineChildMapiahID] =
              THLinePainterBezierCurveLineSegment(
            x: lineChild.x,
            y: lineChild.y,
            controlPoint1X: lineChild.controlPoint1X,
            controlPoint1Y: lineChild.controlPoint1Y,
            controlPoint2X: lineChild.controlPoint2X,
            controlPoint2Y: lineChild.controlPoint2Y,
          );
          break;
        case THStraightLineSegment _:
          lineSegmentsMap[lineChildMapiahID] = THLinePainterStraightLineSegment(
            x: lineChild.x,
            y: lineChild.y,
          );
          break;
      }
    }

    return CustomPaint(
      painter: THLinePainter(
        lineSegmentsMap: lineSegmentsMap,
        linePaint: linePaint,
        thFileDisplayStore: thFileDisplayStore,
      ),
      size: screenSize,
    );
  }
}
