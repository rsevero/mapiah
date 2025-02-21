import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/th_line_paint.dart';
import 'package:mapiah/src/controllers/types/th_point_paint.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/widgets/mixins/mp_get_line_segments_map_mixin.dart';

class MPAddLineWidget extends StatelessWidget with MPGetLineSegmentsMapMixin {
  final TH2FileEditController th2FileEditController;

  MPAddLineWidget({
    required this.th2FileEditController,
    required super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNewLine;

        final (
          LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
          LinkedHashMap<int, Offset> endPointsMap,
        ) = getLineSegmentsAndEndpointsMaps(
          line: th2FileEditController.getNewLine(),
          thFile: th2FileEditController.thFile,
          returnEndpoints: true,
        );

        final THPointPaint pointPaintInfo =
            th2FileEditController.getNewLinePointPaint();
        final double pointRadius = pointPaintInfo.radius;
        final Paint pointPaint = pointPaintInfo.paint;

        final THLinePaint linePaintInfo =
            th2FileEditController.getNewLinePaint();
        final Paint linePaint = linePaintInfo.paint;

        CustomPainter painter = THLinePainter(
          lineSegmentsMap: segmentsMap,
          linePaint: linePaint,
          th2FileEditController: th2FileEditController,
          canvasScale: th2FileEditController.canvasScale,
          canvasTranslation: th2FileEditController.canvasTranslation,
        );

        final List<CustomPainter> painters = [painter];

        for (final Offset endPoint in endPointsMap.values) {
          painter = THPointPainter(
            position: endPoint,
            pointPaint: pointPaint,
            pointRadius: pointRadius,
            th2FileEditController: th2FileEditController,
            canvasScale: th2FileEditController.canvasScale,
            canvasTranslation: th2FileEditController.canvasTranslation,
          );
          painters.add(painter);
        }

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
