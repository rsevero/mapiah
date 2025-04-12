import 'dart:collection';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/aux/th_line_paint.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
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

        if ((selectionController.mpSelectedElements.values.length != 1) ||
            (selectionController.mpSelectedElements.values.first
                is! MPSelectedLine)) {
          return SizedBox.shrink();
        }

        final THPointPaint selectedEndPointPaintInfo =
            th2FileEditController.visualController.getSelectedEndPointPaint();
        final double selectedEndPointHalfSize =
            selectedEndPointPaintInfo.radius;
        final Paint selectedEndPointPaint = selectedEndPointPaintInfo.paint;

        final THPointPaint unselectedEndPointPaintInfo =
            th2FileEditController.visualController.getUnselectablePointPaint();
        final double unselectedEndPointHalfSize =
            unselectedEndPointPaintInfo.radius;
        final Paint unselectedEndPointPaint = unselectedEndPointPaintInfo.paint;

        final THPointPaint unselectedControlPointPaintInfo =
            th2FileEditController.visualController
                .getUnselectedControlPointPaint();
        final double unselectedControlPointRadius =
            unselectedControlPointPaintInfo.radius;
        final Paint unselectedControlPointPaint =
            unselectedControlPointPaintInfo.paint;

        final THPointPaint selectedControlPointPaintInfo = th2FileEditController
            .visualController
            .getSelectedControlPointPaint();
        final double selectedControlPointRadius =
            selectedControlPointPaintInfo.radius;
        final Paint selectedControlPointPaint =
            selectedControlPointPaintInfo.paint;

        final THLinePaint controlPointLinePaintInfo =
            th2FileEditController.visualController.getControlPointLinePaint();
        final Paint controlPointLinePaint = controlPointLinePaintInfo.paint;

        final THLinePaint linePaintInfo =
            th2FileEditController.visualController.getEditLinePaint();
        final Paint linePaint = linePaintInfo.paint;

        final MPSelectableControlPoint? selectedControlPoint =
            selectionController.selectedControlPoint;

        final double canvasScale = th2FileEditController.canvasScale;
        final Offset canvasTranslation =
            th2FileEditController.canvasTranslation;

        final List<CustomPainter> painters = [];

        final THLine line = selectionController
            .mpSelectedElements.values.first.originalElementClone as THLine;

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
          linePaintStroke: linePaint,
          th2FileEditController: th2FileEditController,
          canvasScale: canvasScale,
          canvasTranslation: canvasTranslation,
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
                canvasScale: canvasScale,
                canvasTranslation: canvasTranslation,
              );

              endPointPainters.add(endPointPainter);
              lastEndpoint = point;
            case MPSelectableControlPoint _:
              final bool isSelected = (selectedControlPoint != null) &&
                  (point.element.mpID == selectedControlPoint.element.mpID) &&
                  (point.type == selectedControlPoint.type);
              final THControlPointPainter controlPointPainter =
                  THControlPointPainter(
                controlPointPosition: point.position,
                endPointPosition: lastEndpoint.position,
                pointPaint: isSelected
                    ? selectedControlPointPaint
                    : unselectedControlPointPaint,
                pointRadius: isSelected
                    ? selectedControlPointRadius
                    : unselectedControlPointRadius,
                controlLinePaint: controlPointLinePaint,
                th2FileEditController: th2FileEditController,
                canvasScale: canvasScale,
                canvasTranslation: canvasTranslation,
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
              canvasScale: canvasScale,
              canvasTranslation: canvasTranslation,
            ),
            size: th2FileEditController.screenSize,
          ),
        );
      },
    );
  }
}
