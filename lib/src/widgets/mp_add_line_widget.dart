// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_area_line_creation_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_control_point_painter.dart';
import 'package:mapiah/src/painters/th_end_point_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/widgets/auxiliary/th_line_painter_line_info.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPAddLineWidget extends StatelessWidget with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final TH2FileEditAreaLineCreationController areaLineCreationController;

  MPAddLineWidget({required this.th2FileEditController, required super.key})
    : areaLineCreationController =
          th2FileEditController.areaLineCreationController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerAllElements;
        th2FileEditController.redrawTriggerNewLine;

        final MPVisualController visualController =
            th2FileEditController.visualController;
        final THPointPaint straightPointPaint = visualController
            .getUnselectedStraightEndPointPaint();
        final THPointPaint bezierPointPaint = visualController
            .getUnselectedBezierCurveEndPointPaint();
        final THLinePaint linePaint = visualController.getNewLinePaint();
        final THPointPaint unselectedControlPointPaint = visualController
            .getUnselectedControlPointPaint();
        final THPointPaint selectedControlPointPaint = visualController
            .getSelectedControlPointPaint();
        final Paint controlPointLinePaint = visualController
            .getControlPointLinePaint();
        final List<CustomPainter> painters = [];

        if (areaLineCreationController.newLine == null) {
          if (areaLineCreationController.lineStartScreenPosition != null) {
            final Offset startPoint = th2FileEditController
                .offsetScreenToCanvas(
                  areaLineCreationController.lineStartScreenPosition!,
                );
            final CustomPainter painter = THEndPointPainter(
              position: startPoint,
              pointPaint: straightPointPaint,
              isSmooth: false,
              th2FileEditController: th2FileEditController,
            );

            painters.add(painter);
          }
        } else {
          final THLine newLine = areaLineCreationController.getNewLine();
          final (
            LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
            LinkedHashMap<int, THLineSegment> lineSegments,
          ) = getLineSegmentsAndEndpointsMaps(
            line: newLine,
            th2File: th2FileEditController.th2File,
            returnLineSegments: true,
          );
          final THLinePainterLineInfo lineInfo = THLinePainterLineInfo(
            line: newLine,
            showLineDirectionTicks: false,
            showMarksOnLineSegments: false,
            showSizeOrientationOnLineSegments: false,
            th2FileEditController: th2FileEditController,
          );
          final CustomPainter painter = THLinePainter(
            lineInfo: lineInfo,
            lineSegmentsMap: segmentsMap,
            linePaint: linePaint,
            th2FileEditController: th2FileEditController,
          );

          painters.add(painter);

          final List<CustomPainter> endPointPainters = [];

          for (final THLineSegment lineSegment in lineSegments.values) {
            final THPointPaint pointPaint =
                (lineSegment is THStraightLineSegment)
                ? straightPointPaint
                : bezierPointPaint;
            final CustomPainter endPointPainter = THEndPointPainter(
              position: lineSegment.endPoint.coordinates,
              pointPaint: pointPaint,
              isSmooth: MPCommandOptionAux.isSmooth(lineSegment),
              th2FileEditController: th2FileEditController,
            );

            endPointPainters.add(endPointPainter);
          }

          // Control points for the last segment (visible only during drag).
          // Requires at least 2 segments so we can find the segment-start
          // anchor.
          if (areaLineCreationController.isNewLineDragging &&
              (lineSegments.length >= 2)) {
            final List<THLineSegment> segmentList = lineSegments.values
                .toList();
            final THLineSegment lastLineSegment = segmentList.last;

            if (lastLineSegment is THBezierCurveLineSegment) {
              final Offset startPointPosition =
                  segmentList[segmentList.length - 2].endPoint.coordinates;
              final Offset endPointPosition =
                  lastLineSegment.endPoint.coordinates;

              // In XTherionCubicSmooth mode, the pending CP1 is the mouse
              // position (black). In MapiahQuadratic mode it is null (no
              // handle at the mouse).
              final Offset? pendingCP1 = areaLineCreationController
                  .newLinePendingControlPoint1CanvasCoordinates;
              final bool xTherionDragging = (pendingCP1 != null);

              // CP1 — always white (never directly under the mouse).
              painters.add(
                THControlPointPainter(
                  controlPointPosition:
                      lastLineSegment.controlPoint1.coordinates,
                  endPointPosition: startPointPosition,
                  pointPaint: unselectedControlPointPaint,
                  controlLinePaint: controlPointLinePaint,
                  th2FileEditController: th2FileEditController,
                ),
              );

              // CP2 — always white.
              painters.add(
                THControlPointPainter(
                  controlPointPosition:
                      lastLineSegment.controlPoint2.coordinates,
                  endPointPosition: endPointPosition,
                  pointPaint: unselectedControlPointPaint,
                  controlLinePaint: controlPointLinePaint,
                  th2FileEditController: th2FileEditController,
                ),
              );

              // XTherionCubicSmooth only: the ghost CP1 for the next
              // segment, at the mouse position → painted black.
              if (xTherionDragging) {
                painters.add(
                  THControlPointPainter(
                    controlPointPosition: pendingCP1,
                    endPointPosition: endPointPosition,
                    pointPaint: selectedControlPointPaint,
                    controlLinePaint: controlPointLinePaint,
                    th2FileEditController: th2FileEditController,
                  ),
                );
              }
            }
          }

          // End-point painters on top of control point painters.
          painters.addAll(endPointPainters);
        }

        return RepaintBoundary(
          child: CustomPaint(
            painter: THElementsPainter(
              painters: painters,
              th2FileEditController: th2FileEditController,
            ),
            size: th2FileEditController.screenSize,
          ),
        );
      },
    );
  }
}
