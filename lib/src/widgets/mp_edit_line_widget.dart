import 'dart:collection';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/th_line_paint.dart';
import 'package:mapiah/src/controllers/types/th_point_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/th_control_point_painter.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_end_point_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/widgets/mixins/mp_get_line_segments_map_mixin.dart';

class MPEditLineWidget extends StatelessWidget with MPGetLineSegmentsMapMixin {
  final TH2FileEditController th2FileEditController;
  final TH2FileEditSelectionController selectionController;

  MPEditLineWidget({
    required this.th2FileEditController,
    required super.key,
  }) : selectionController = th2FileEditController.selectionController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerEditLine;

        if ((selectionController.selectedElements.values.length != 1) ||
            (selectionController.selectedElements.values.first
                is! MPSelectedLine)) {
          return SizedBox.shrink();
        }

        final THPointPaint selectedEndPointPaintInfo =
            th2FileEditController.getSelectedEndPointPaint();
        final double selectedEndPointHalfSize =
            selectedEndPointPaintInfo.radius;
        final Paint selectedEndPointPaint = selectedEndPointPaintInfo.paint;

        final THPointPaint unselectedEndPointPaintInfo =
            th2FileEditController.getUnselectablePointPaint();
        final double unselectedEndPointHalfSize =
            unselectedEndPointPaintInfo.radius;
        final Paint unselectedEndPointPaint = unselectedEndPointPaintInfo.paint;

        final THPointPaint controlPointPaintInfo =
            th2FileEditController.getControlPointPaint();
        final double controlPointRadius = controlPointPaintInfo.radius;
        final Paint controlPointPaint = controlPointPaintInfo.paint;

        final THLinePaint controlPointLinePaintInfo =
            th2FileEditController.getControlPointLinePaint();
        final Paint controlPointLinePaint = controlPointLinePaintInfo.paint;

        final THLinePaint linePaintInfo =
            th2FileEditController.getEditLinePaint();
        final Paint linePaint = linePaintInfo.paint;

        final List<CustomPainter> painters = [];

        final THLine line = selectionController
            .selectedElements.values.first.originalElementClone as THLine;

        final (
          LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
          _,
        ) = getLineSegmentsAndEndpointsMaps(
          line: line,
          thFile: th2FileEditController.thFile,
          returnLineSegments: false,
        );

        CustomPainter painter = THLinePainter(
          lineSegmentsMap: segmentsMap,
          linePaint: linePaint,
          th2FileEditController: th2FileEditController,
          canvasScale: th2FileEditController.canvasScale,
          canvasTranslation: th2FileEditController.canvasTranslation,
        );

        painters.add(painter);

        final List<THEndPointPainter> endPointPainters = [];
        final Set<MPSelectableEndControlPoint> endControlPoints =
            selectionController.selectableEndControlPoints;
        late MPSelectableEndControlPoint lastEndpoint;

        for (final MPSelectableEndControlPoint point in endControlPoints) {
          switch (point) {
            case MPSelectableEndPoint _:
              final THLineSegment lineSegment = point.element as THLineSegment;
              late Paint pointPaint;
              late double pointHalfLength;

              if (selectionController.getIsLineSegmentSelected(lineSegment)) {
                pointPaint = selectedEndPointPaint;
                pointHalfLength = selectedEndPointHalfSize;
              } else {
                pointPaint = unselectedEndPointPaint;
                pointHalfLength = unselectedEndPointHalfSize;
              }

              final THEndPointPainter endPointPainter = THEndPointPainter(
                position: point.position,
                pointPaint: pointPaint,
                halfLength: pointHalfLength,
                isSmooth: MPCommandOptionAux.isSmooth(lineSegment),
                th2FileEditController: th2FileEditController,
                canvasScale: th2FileEditController.canvasScale,
                canvasTranslation: th2FileEditController.canvasTranslation,
              );

              endPointPainters.add(endPointPainter);
              lastEndpoint = point;
            case MPSelectableControlPoint _:
              final THControlPointPainter controlPointPainter =
                  THControlPointPainter(
                controlPointPosition: point.position,
                endPointPosition: lastEndpoint.position,
                pointPaint: controlPointPaint,
                controlLinePaint: controlPointLinePaint,
                pointRadius: controlPointRadius,
                th2FileEditController: th2FileEditController,
                canvasScale: th2FileEditController.canvasScale,
                canvasTranslation: th2FileEditController.canvasTranslation,
              );
              painters.add(controlPointPainter);
            default:
              throw UnimplementedError('Unknown MPSelectableEndControlPoint');
          }
        }

        painters.addAll(endPointPainters);

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
