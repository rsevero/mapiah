// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_scrap_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/widgets/auxiliary/th_line_painter_line_info.dart';

mixin MPLinePaintingMixin {
  (
    LinkedHashMap<int, THLinePainterLineSegment>,
    LinkedHashMap<int, THLineSegment>,
  )
  getLineSegmentsAndEndpointsMaps({
    required THLine line,
    required TH2File th2File,
    required bool returnLineSegments,
  }) {
    final LinkedHashMap<int, THLinePainterLineSegment> lineSegmentsMap =
        LinkedHashMap<int, THLinePainterLineSegment>();
    final LinkedHashMap<int, THLineSegment> lineEndpointsMap =
        LinkedHashMap<int, THLineSegment>();

    /// We need to get childrenMPIDs and filter for line segments later. Using
    /// line.getLineSegments(th2File) here messes with the updating of the
    /// line segments during interactive editing.
    final List<int> lineChildrenMPIDs = line.childrenMPIDs;

    bool isFirst = true;

    for (int lineSegmentMPID in lineChildrenMPIDs) {
      final THElement lineSegment = th2File.elementByMPID(lineSegmentMPID);

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
    required bool isFromActiveScrap,
    THScrapPaint? parentScrapPaint,
    required TH2FileEditController th2FileEditController,
  }) {
    final TH2File th2File = th2FileEditController.th2File;
    final MPVisualController visualController =
        th2FileEditController.visualController;
    final bool showLinePoints = mpLocator.mpSettingsController
        .getBoolWithDefault(MPSettingID.TH2Edit_ShowLinePoints);
    final (
      LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
      _,
    ) = getLineSegmentsAndEndpointsMaps(
      line: line,
      th2File: th2File,
      returnLineSegments: false,
    );
    final THLinePainterLineInfo lineInfo = THLinePainterLineInfo(
      line: line,
      showLineDirectionTicks: showLineDirectionTicks,
      showMarksOnLineSegments: true,
      showSizeOrientationOnLineSegments: false,
      th2FileEditController: th2FileEditController,
    );
    final THLineType lineType = line.lineType;
    final bool lineIsTHInvisible = isLineSelected
        ? false
        : !MPCommandOptionAux.isTHVisible(line);
    final bool lineHasID = isLineSelected
        ? false
        : MPCommandOptionAux.hasID(line);
    final bool lineIsSlopeWithoutLSize = isLineSelected
        ? false
        : line.isSlopeWithoutLSize;

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
                lineIsTHInvisible: lineIsTHInvisible,
                isFromActiveScrap: isFromActiveScrap,
                lineHasID: lineHasID,
                lineIsSlopeWithoutLSize: lineIsSlopeWithoutLSize,
                parentScrapPaint: parentScrapPaint,
              );
      } else {
        final THArea lineArea = lineInfo.parentArea!;

        linePaint = isLineSelected
            ? visualController.getSelectedAreaPaint(lineArea)
            : visualController.getUnselectedAreaPaint(
                areaType: lineArea.areaType,
                subtype: MPCommandOptionAux.getSubtype(lineArea),
                areaHasID: MPCommandOptionAux.hasID(lineArea),
                areaIsTHInvisible: !MPCommandOptionAux.isTHVisible(lineArea),
                isFromActiveScrap: isFromActiveScrap,
                parentScrapPaint: parentScrapPaint,
              );
      }

      final THLinePainter painter = THLinePainter(
        lineInfo: lineInfo,
        lineSegmentsMap: segmentsMap,
        linePaint: linePaint,
        showLinePoints: showLinePoints,
        lineDecorator: visualController.getLineDecorator(lineType),
        th2FileEditController: th2FileEditController,
      );

      return [painter];
    } else {
      final List<THLinePainter> painters = [];
      final LinkedHashMap<int, int> subtypeLineSegmentsMap =
          line.subtypeLineSegmentMPIDsByLineSegmentIndex;
      final int subtypeLineSegmentsCount = subtypeLineSegmentsMap.length;
      final int segmentsMapMaxIndex = segmentsMap.length - 1;

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
                : th2File.elementByMPID(
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
                  lineIsTHInvisible: lineIsTHInvisible,
                  lineHasID: lineHasID,
                  lineIsSlopeWithoutLSize: lineIsSlopeWithoutLSize,
                  isFromActiveScrap: isFromActiveScrap,
                  parentScrapPaint: parentScrapPaint,
                );
        } else {
          final THArea area = lineInfo.parentArea!;

          linePaint = isLineSelected
              ? visualController.getSelectedAreaPaint(area)
              : visualController.getUnselectedAreaPaint(
                  areaType: area.areaType,
                  subtype: MPCommandOptionAux.getSubtype(area),
                  areaHasID: MPCommandOptionAux.hasID(area),
                  areaIsTHInvisible: !MPCommandOptionAux.isTHVisible(area),
                  isFromActiveScrap: isFromActiveScrap,
                  parentScrapPaint: parentScrapPaint,
                );
        }

        painters.add(
          THLinePainter(
            lineInfo: lineInfo,
            lineSegmentsMap: lineSegmentSubsetMap,
            linePaint: linePaint,
            showLinePoints: showLinePoints,
            lineDecorator: visualController.getLineDecorator(lineType),
            th2FileEditController: th2FileEditController,
          ),
        );

        startIndex = endIndex;
      }

      return painters;
    }
  }
}
