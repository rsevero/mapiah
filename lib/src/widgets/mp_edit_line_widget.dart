import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/th_line_paint.dart';
import 'package:mapiah/src/controllers/types/th_point_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/th_control_point_painter.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/th_end_point_painter.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/widgets/mixins/mp_get_line_segments_map_mixin.dart';

class MPEditLineWidget extends StatelessWidget with MPGetLineSegmentsMapMixin {
  final TH2FileEditController th2FileEditController;

  MPEditLineWidget({
    required this.th2FileEditController,
    required super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNewLine;

        if ((th2FileEditController.selectedElements.values.length != 1) ||
            (th2FileEditController.selectedElements.values.first
                is! MPSelectedLine)) {
          return SizedBox.shrink();
        }

        final THPointPaint pointPaintInfo =
            th2FileEditController.getNewLinePointPaint();
        final double pointRadius = pointPaintInfo.radius;
        final double pointWidth = pointRadius * 2;
        final Paint pointPaint = pointPaintInfo.paint;

        final THLinePaint linePaintInfo =
            th2FileEditController.getNewLinePaint();
        final Paint linePaint = linePaintInfo.paint;

        final List<CustomPainter> painters = [];

        final THLine line = th2FileEditController.thFile.elementByMapiahID(
                th2FileEditController.selectedElements.values.first.mapiahID)
            as THLine;

        final (
          LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
          LinkedHashMap<int, THLineSegment> lineSegments,
        ) = getLineSegmentsAndEndpointsMaps(
          line: line,
          thFile: th2FileEditController.thFile,
          returnLineSegments: true,
        );

        CustomPainter painter = THLinePainter(
          lineSegmentsMap: segmentsMap,
          linePaint: linePaint,
          th2FileEditController: th2FileEditController,
          canvasScale: th2FileEditController.canvasScale,
          canvasTranslation: th2FileEditController.canvasTranslation,
        );

        painters.add(painter);

        // final THLineSegment lastSegment = th2FileEditController.thFile
        //     .elementByMapiahID(line.childrenMapiahID.last) as THLineSegment;

        // if ((lineSegments.length >= 2) &&
        //     (lastSegment is THBezierCurveLineSegment)) {
        //   final THLinePaint controlLinePaint =
        //       th2FileEditController.getControlLinePaint();
        //   final List<int> keys = lineSegments.keys.toList();
        //   final Offset secondToLastSegmentPosition =
        //       lineSegments[keys.elementAt(keys.length - 2)]!
        //           .endPoint
        //           .coordinates;

        //   final THControlPointPainter controlPoint1Painter =
        //       THControlPointPainter(
        //     controlPointPosition: lastSegment.controlPoint1.coordinates,
        //     endPointPosition: secondToLastSegmentPosition,
        //     pointPaint: pointPaint,
        //     controlLinePaint: controlLinePaint.paint,
        //     pointRadius: pointRadius,
        //     th2FileEditController: th2FileEditController,
        //     canvasScale: th2FileEditController.canvasScale,
        //     canvasTranslation: th2FileEditController.canvasTranslation,
        //   );
        //   painters.add(controlPoint1Painter);

        //   final THControlPointPainter controlPoint2Painter =
        //       THControlPointPainter(
        //     controlPointPosition: lastSegment.controlPoint2.coordinates,
        //     endPointPosition: lastSegment.endPoint.coordinates,
        //     pointPaint: pointPaint,
        //     controlLinePaint: controlLinePaint.paint,
        //     pointRadius: pointRadius,
        //     th2FileEditController: th2FileEditController,
        //     canvasScale: th2FileEditController.canvasScale,
        //     canvasTranslation: th2FileEditController.canvasTranslation,
        //   );
        //   painters.add(controlPoint2Painter);

        //   for (final THLineSegment lineSegment in lineSegments.values) {
        //     painter = THEndPointPainter(
        //       position: lineSegment.endPoint.coordinates,
        //       pointPaint: pointPaint,
        //       width: pointWidth,
        //       isSmooth: MPCommandOptionAux.isSmooth(lineSegment),
        //       th2FileEditController: th2FileEditController,
        //       canvasScale: th2FileEditController.canvasScale,
        //       canvasTranslation: th2FileEditController.canvasTranslation,
        //     );
        //     painters.add(painter);
        //   }
        // }

        return RepaintBoundary(
          child: CustomPaint(
            painter: THElementsPainter(
              painters: painters,
              th2FileEditController: th2FileEditController,
              canvasScale: th2FileEditController.canvasScale,
              canvasTranslation: th2FileEditController.canvasTranslation,
            ),
            size: th2FileEditController.screenSize,
          ),
        );
      },
    );
  }
}
