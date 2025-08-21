import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/th_control_point_painter.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/th_end_point_painter.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPAddLineWidget extends StatelessWidget with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final TH2FileEditElementEditController elementEditController;

  MPAddLineWidget({required this.th2FileEditController, required super.key})
    : elementEditController = th2FileEditController.elementEditController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNewLine;

        final THPointPaint pointPaint = th2FileEditController.visualController
            .getNewLinePointPaint();

        final THLinePaint linePaint = th2FileEditController.visualController
            .getNewLinePaint();

        final List<CustomPainter> painters = [];

        if (elementEditController.newLine == null) {
          if (elementEditController.lineStartScreenPosition != null) {
            final Offset startPoint = th2FileEditController
                .offsetScreenToCanvas(
                  elementEditController.lineStartScreenPosition!,
                );

            final painter = THEndPointPainter(
              position: startPoint,
              pointPaint: pointPaint,
              isSmooth: false,
              th2FileEditController: th2FileEditController,
            );
            painters.add(painter);
          }
        } else {
          final THLine newLine = elementEditController.getNewLine();

          final (
            LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
            LinkedHashMap<int, THLineSegment> lineSegments,
          ) = getLineSegmentsAndEndpointsMaps(
            line: newLine,
            thFile: th2FileEditController.thFile,
            returnLineSegments: true,
          );

          CustomPainter painter = THLinePainter(
            line: newLine,
            lineSegmentsMap: segmentsMap,
            linePaint: linePaint,
            showLineDirectionTicks: false,
            th2FileEditController: th2FileEditController,
          );

          painters.add(painter);

          final THLineSegment lastSegment = th2FileEditController.thFile
              .lineSegmentByMPID(lineSegments.keys.last);

          if ((lineSegments.length >= 2) &&
              (lastSegment is THBezierCurveLineSegment)) {
            final Paint controlLinePaint = th2FileEditController
                .visualController
                .getControlLinePaint();
            final List<int> keys = lineSegments.keys.toList();
            final Offset secondToLastSegmentPosition =
                lineSegments[keys.elementAt(keys.length - 2)]!
                    .endPoint
                    .coordinates;

            final THControlPointPainter controlPoint1Painter =
                THControlPointPainter(
                  controlPointPosition: lastSegment.controlPoint1.coordinates,
                  endPointPosition: secondToLastSegmentPosition,
                  pointPaint: pointPaint,
                  controlLinePaint: controlLinePaint,
                  th2FileEditController: th2FileEditController,
                );
            painters.add(controlPoint1Painter);

            final THControlPointPainter controlPoint2Painter =
                THControlPointPainter(
                  controlPointPosition: lastSegment.controlPoint2.coordinates,
                  endPointPosition: lastSegment.endPoint.coordinates,
                  pointPaint: pointPaint,
                  controlLinePaint: controlLinePaint,
                  th2FileEditController: th2FileEditController,
                );
            painters.add(controlPoint2Painter);
          }

          for (final THLineSegment lineSegment in lineSegments.values) {
            painter = THEndPointPainter(
              position: lineSegment.endPoint.coordinates,
              pointPaint: pointPaint,
              isSmooth: MPCommandOptionAux.isSmooth(lineSegment),
              th2FileEditController: th2FileEditController,
            );
            painters.add(painter);
          }
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
