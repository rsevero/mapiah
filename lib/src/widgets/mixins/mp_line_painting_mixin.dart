import 'dart:collection';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';

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

    /// We need to get childrenMPIDs and filter for line segments later. Using
    /// line.getLineSegments(thFile) here messes with the updating of the
    /// line segments during interactive editing.
    final List<int> lineChildrenMPIDs = line.childrenMPIDs;

    bool isFirst = true;

    for (int lineSegmentMPID in lineChildrenMPIDs) {
      final THElement lineSegment = thFile.elementByMPID(lineSegmentMPID);

      if (lineSegment is! THLineSegment) {
        continue;
      }

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
      }
    }

    return (lineSegmentsMap, lineEndpointsMap);
  }

  THLinePainter getLinePainter({
    required THLine line,
    required bool isLineSelected,
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
    final THLinePainterLineInfo lineInfo = THLinePainterLineInfo(
      line: line,
      showLineDirectionTicks: showLineDirectionTicks,
      th2FileEditController: th2FileEditController,
    );
    final MPVisualController visualController =
        th2FileEditController.visualController;
    final THLinePaint linePaint = isLineSelected
        ? ((lineInfo.parentArea == null)
              ? visualController.getSelectedLinePaint(line)
              : visualController.getSelectedAreaPaint(lineInfo.parentArea!))
        : ((lineInfo.parentArea == null)
              ? visualController.getUnselectedLinePaint(line)
              : visualController.getUnselectedAreaPaint(lineInfo.parentArea!));

    return THLinePainter(
      lineInfo: lineInfo,
      lineSegmentsMap: segmentsMap,
      linePaint: linePaint,
      th2FileEditController: th2FileEditController,
    );
  }
}

class THLinePainterLineInfo {
  late final int mpID;
  late final THLinePaint lineDirectionTicksPaint;
  late final bool addLineDirectionTicks;
  late final bool isReverse;
  late final THArea? parentArea;

  THLinePainterLineInfo({
    required THLine line,
    required bool showLineDirectionTicks,
    required TH2FileEditController th2FileEditController,
  }) {
    mpID = line.mpID;
    isReverse = MPCommandOptionAux.isReverse(line);
    lineDirectionTicksPaint = th2FileEditController.visualController
        .getLineDirectionTickPaint(line: line, reverse: isReverse);
    addLineDirectionTicks =
        showLineDirectionTicks && th2FileEditController.isFromActiveScrap(line);

    final THFile thFile = th2FileEditController.thFile;
    final int? areaMPID = thFile.getAreaMPIDByLineMPID(mpID);

    parentArea = (areaMPID == null) ? null : thFile.areaByMPID(areaMPID);
  }
}
