import 'dart:collection';

import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';

mixin MPLinePaintingMixin {
  (
    LinkedHashMap<int, THLinePainterLineSegment>,
    LinkedHashMap<int, THLineSegment>,
  )
  getLineSegmentsAndEndpointsMaps({
    required THLine line,
    required THFile thFile,
    required bool returnLineSegments,
  }) {
    final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLinePainterLineSegment>();
    final LinkedHashMap<int, THLineSegment> lineEndpointsMap =
        LinkedHashMap<int, THLineSegment>();
    final List<int> lineChildrenMPIDs = line.childrenMPIDs;
    bool isFirst = true;

    for (int lineChildMPID in lineChildrenMPIDs) {
      final THElement lineChild = thFile.elementByMPID(lineChildMPID);

      if (lineChild is! THLineSegment) {
        continue;
      }

      if (returnLineSegments) {
        lineEndpointsMap[lineChildMPID] = lineChild;
      }

      if (isFirst) {
        lineSegmentsMap[lineChildMPID] = THLinePainterStraightLineSegment(
          x: lineChild.x,
          y: lineChild.y,
        );
        isFirst = false;
        continue;
      }

      switch (lineChild) {
        case THBezierCurveLineSegment _:
          lineSegmentsMap[lineChildMPID] = THLinePainterBezierCurveLineSegment(
            x: lineChild.x,
            y: lineChild.y,
            controlPoint1X: lineChild.controlPoint1X,
            controlPoint1Y: lineChild.controlPoint1Y,
            controlPoint2X: lineChild.controlPoint2X,
            controlPoint2Y: lineChild.controlPoint2Y,
          );
          break;
        case THStraightLineSegment _:
          lineSegmentsMap[lineChildMPID] = THLinePainterStraightLineSegment(
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

  THLinePainter getLinePainter({
    required THLine line,
    required THLinePaint linePaint,
    required bool showLineDirectionTicks,
    required TH2FileEditController th2FileEditController,
  }) {
    final (
      LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
      _,
    ) = getLineSegmentsAndEndpointsMaps(
      line: line,
      thFile: th2FileEditController.thFile,
      returnLineSegments: false,
    );

    return THLinePainter(
      line: line,
      lineSegmentsMap: segmentsMap,
      linePaint: linePaint,
      showLineDirectionTicks: showLineDirectionTicks,
      th2FileEditController: th2FileEditController,
    );
  }
}
