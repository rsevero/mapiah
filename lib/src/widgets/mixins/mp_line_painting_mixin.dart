import 'dart:collection';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
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

  List<THLinePainter> getLinePainters({
    required THLine line,
    required bool isLineSelected,
    required bool showLineDirectionTicks,
    required TH2FileEditController th2FileEditController,
  }) {
    final THFile thFile = th2FileEditController.thFile;
    final MPVisualController visualController =
        th2FileEditController.visualController;
    final (
      LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
      _,
    ) = getLineSegmentsAndEndpointsMaps(
      line: line,
      thFile: thFile,
      returnLineSegments: false,
    );
    final THLinePainterLineInfo lineInfo = THLinePainterLineInfo(
      line: line,
      showLineDirectionTicks: showLineDirectionTicks,
      th2FileEditController: th2FileEditController,
    );
    final THLineType lineType = line.lineType;
    final bool lineIsTHInvisible = isLineSelected
        ? false
        : !MPCommandOptionAux.isTHVisible(line);
    final bool lineHasID = isLineSelected
        ? false
        : MPCommandOptionAux.hasID(line);

    if (line.subtypeLineSegmentMPIDsByLineSegmentIndex.isEmpty) {
      final THLinePaint linePaint;

      if (lineInfo.parentArea == null) {
        final String? subtype = MPCommandOptionAux.getSubtype(line);

        linePaint = isLineSelected
            ? visualController.getSelectedLinePaint(
                lineType: lineType,
                subtype: subtype,
              )
            : visualController.getUnselectedLinePaint(
                lineType: lineType,
                subtype: subtype,
                lineParentMPID: line.parentMPID,
                lineIsTHInvisible: lineIsTHInvisible,
                lineHasID: lineHasID,
              );
      } else {
        linePaint = isLineSelected
            ? visualController.getSelectedAreaPaint(lineInfo.parentArea!)
            : visualController.getUnselectedAreaPaint(lineInfo.parentArea!);
      }

      final THLinePainter painter = THLinePainter(
        lineInfo: lineInfo,
        lineSegmentsMap: segmentsMap,
        linePaint: linePaint,
        th2FileEditController: th2FileEditController,
      );

      return [painter];
    } else {
      final List<THLinePainter> painters = [];
      final LinkedHashMap<int, int> subtypeLineSegmentsMap =
          line.subtypeLineSegmentMPIDsByLineSegmentIndex;
      final int subtypeLineSegmentsCount = subtypeLineSegmentsMap.length;
      final int segmentsMapMaxIndex = segmentsMap.length - 1;
      final int lineParentMPID = line.parentMPID;

      int startIndex = 0;

      for (int i = 0; i <= subtypeLineSegmentsCount; i++) {
        final int endIndex = (i < subtypeLineSegmentsCount)
            ? subtypeLineSegmentsMap.keys.elementAt(i)
            : segmentsMapMaxIndex;
        final LinkedHashMap<int, THLinePainterLineSegment>
        lineSegmentSubsetMap =
            LinkedHashMap<int, THLinePainterLineSegment>.fromEntries(
              segmentsMap.entries.toList().sublist(startIndex, endIndex + 1),
            );
        final THLinePaint linePaint;

        if (lineInfo.parentArea == null) {
          final String? subtype = MPCommandOptionAux.getSubtype(
            (i == 0)
                ? line
                : thFile.elementByMPID(
                    subtypeLineSegmentsMap.values.elementAt(i - 1),
                  ),
          );

          linePaint = isLineSelected
              ? visualController.getSelectedLinePaint(
                  lineType: lineType,
                  subtype: subtype,
                )
              : visualController.getUnselectedLinePaint(
                  lineType: lineType,
                  subtype: subtype,
                  lineParentMPID: lineParentMPID,
                  lineIsTHInvisible: lineIsTHInvisible,
                  lineHasID: lineHasID,
                );
        } else {
          linePaint = isLineSelected
              ? visualController.getSelectedAreaPaint(lineInfo.parentArea!)
              : visualController.getUnselectedAreaPaint(lineInfo.parentArea!);
        }

        painters.add(
          THLinePainter(
            lineInfo: lineInfo,
            lineSegmentsMap: lineSegmentSubsetMap,
            linePaint: linePaint,
            th2FileEditController: th2FileEditController,
          ),
        );

        startIndex = endIndex;
      }

      return painters;
    }
  }
}

class THLinePainterLineInfo {
  late final int mpID;
  late final THLinePaint lineDirectionTicksPaint;
  late final bool addLineDirectionTicks;
  late final bool isReversed;
  late final THArea? parentArea;

  THLinePainterLineInfo({
    required THLine line,
    required bool showLineDirectionTicks,
    required TH2FileEditController th2FileEditController,
  }) {
    mpID = line.mpID;
    isReversed = MPCommandOptionAux.isReversed(line);
    lineDirectionTicksPaint = th2FileEditController.visualController
        .getLineDirectionTickPaint(line: line, reverse: isReversed);
    addLineDirectionTicks =
        showLineDirectionTicks && th2FileEditController.isFromActiveScrap(line);

    final THFile thFile = th2FileEditController.thFile;
    final int? areaMPID = thFile.getAreaMPIDByLineMPID(mpID);

    parentArea = (areaMPID == null) ? null : thFile.areaByMPID(areaMPID);
  }
}
