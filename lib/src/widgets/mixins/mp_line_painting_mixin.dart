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
    final List<THLineSegment> lineSegments = line.getLineSegments(thFile);

    bool isFirst = true;

    for (THLineSegment lineSegment in lineSegments) {
      final int lineSegmentMPID = lineSegment.mpID;

      if (returnLineSegments) {
        lineEndpointsMap[lineSegmentMPID] = lineSegment;
      }

      if (isFirst) {
        lineSegmentsMap[lineSegmentMPID] = THLinePainterStraightLineSegment(
          x: lineSegment.x,
          y: lineSegment.y,
        );
        isFirst = false;
        continue;
      }

      switch (lineSegment) {
        case THBezierCurveLineSegment _:
          lineSegmentsMap[lineSegmentMPID] =
              THLinePainterBezierCurveLineSegment(
                x: lineSegment.x,
                y: lineSegment.y,
                controlPoint1X: lineSegment.controlPoint1X,
                controlPoint1Y: lineSegment.controlPoint1Y,
                controlPoint2X: lineSegment.controlPoint2X,
                controlPoint2Y: lineSegment.controlPoint2Y,
              );
        case THStraightLineSegment _:
          lineSegmentsMap[lineSegmentMPID] = THLinePainterStraightLineSegment(
            x: lineSegment.x,
            y: lineSegment.y,
          );
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
