import 'dart:collection';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/painters/th_control_point_painter.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_end_point_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPLineEditWidget extends StatelessWidget with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final TH2FileEditSelectionController selectionController;

  MPLineEditWidget({required this.th2FileEditController, required super.key})
    : selectionController = th2FileEditController.selectionController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerEditLine;

        if ((selectionController.mpSelectedElementsLogical.values.length !=
                1) ||
            (selectionController.mpSelectedElementsLogical.values.first
                is! MPSelectedLine)) {
          return SizedBox.shrink();
        }

        final THPointPaint selectedEndPointPaint = th2FileEditController
            .visualController
            .getSelectedEndPointPaint();

        final THPointPaint unselectedEndPointPaint = th2FileEditController
            .visualController
            .getUnselectedEndPointPaint();

        final THPointPaint unselectedControlPointPaint = th2FileEditController
            .visualController
            .getUnselectedControlPointPaint();

        final THPointPaint selectedControlPointPaint = th2FileEditController
            .visualController
            .getSelectedControlPointPaint();

        final Paint controlPointLinePaint = th2FileEditController
            .visualController
            .getControlPointLinePaint();

        final THLinePaint linePaint = th2FileEditController.visualController
            .getEditLinePaint();

        final MPSelectedEndControlPoint? selectedControlPoint;

        if (selectionController.selectedEndControlPoints.length == 1) {
          final MPSelectedEndControlPoint selectEndControlPoint =
              selectionController.selectedEndControlPoints.values.first;
          final MPEndControlPointType selectEndControlPointType =
              selectEndControlPoint.type;

          selectedControlPoint =
              ((selectEndControlPointType ==
                      MPEndControlPointType.controlPoint1) ||
                  (selectEndControlPointType ==
                      MPEndControlPointType.controlPoint2))
              ? selectEndControlPoint
              : null;
        } else {
          selectedControlPoint = null;
        }
        final List<CustomPainter> painters = [];

        final THLine line =
            selectionController
                    .mpSelectedElementsLogical
                    .values
                    .first
                    .originalElementClone
                as THLine;

        final (
          LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
          _,
        ) = getLineSegmentsAndEndpointsMaps(
          line: line,
          thFile: th2FileEditController.thFile,
          returnLineSegments: false,
        );

        CustomPainter painter = THLinePainter(
          line: line,
          lineSegmentsMap: segmentsMap,
          linePaint: linePaint,
          showLineDirectionTicks: true,
          th2FileEditController: th2FileEditController,
        );

        painters.add(painter);

        final List<THEndPointPainter> endPointPainters = [];
        final Set<MPSelectableEndControlPoint> endControlPoints =
            selectionController.selectableEndControlPoints;
        late MPSelectableEndControlPoint lastEndpoint;

        for (final MPSelectableEndControlPoint point in endControlPoints) {
          switch (point.type) {
            case MPEndControlPointType.endPointBezierCurve:
            case MPEndControlPointType.endPointStraight:
              final THLineSegment lineSegment = point.element as THLineSegment;
              final THPointPaint pointPaint =
                  selectionController.getIsLineSegmentSelected(lineSegment)
                  ? selectedEndPointPaint
                  : unselectedEndPointPaint;
              final THEndPointPainter endPointPainter = THEndPointPainter(
                position: point.position,
                pointPaint: pointPaint,
                isSmooth: MPCommandOptionAux.isSmooth(lineSegment),
                th2FileEditController: th2FileEditController,
              );

              endPointPainters.add(endPointPainter);
              lastEndpoint = point;
            case MPEndControlPointType.controlPoint1:
            case MPEndControlPointType.controlPoint2:
              final bool isSelected =
                  (selectedControlPoint != null) &&
                  (point.element.mpID ==
                      selectedControlPoint.originalElementClone.mpID) &&
                  (point.type == selectedControlPoint.type);
              final THControlPointPainter controlPointPainter =
                  THControlPointPainter(
                    controlPointPosition: point.position,
                    endPointPosition: lastEndpoint.position,
                    pointPaint: isSelected
                        ? selectedControlPointPaint
                        : unselectedControlPointPaint,
                    controlLinePaint: controlPointLinePaint,
                    th2FileEditController: th2FileEditController,
                  );

              painters.add(controlPointPainter);
          }
        }

        painters.addAll(endPointPainters);

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
