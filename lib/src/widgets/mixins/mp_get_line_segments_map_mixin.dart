import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

mixin MPGetLineSegmentsMapMixin {
  (LinkedHashMap<int, THLinePainterLineSegment>, LinkedHashMap<int, Offset>)
      getLineSegmentsAndEndpointsMaps({
    required THLine line,
    required THFile thFile,
    required bool returnEndpoints,
  }) {
    final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLinePainterLineSegment>();
    final LinkedHashMap<int, Offset> lineEndpointsMap =
        LinkedHashMap<int, Offset>();
    final Set<int> lineChildrenMapiahIDs = line.childrenMapiahID;
    bool isFirst = true;

    for (int lineChildMapiahID in lineChildrenMapiahIDs) {
      final THElement lineChild = thFile.elementByMapiahID(lineChildMapiahID);

      if (lineChild is! THLineSegment) {
        continue;
      }

      if (returnEndpoints) {
        lineEndpointsMap[lineChildMapiahID] = Offset(lineChild.x, lineChild.y);
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
        default:
          continue;
      }
    }

    return (lineSegmentsMap, lineEndpointsMap);
  }
}
