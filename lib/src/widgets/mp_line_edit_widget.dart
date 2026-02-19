import 'dart:collection';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/auxiliary/mp_line_segment_size_orientation_info.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/painters/th_control_point_painter.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_end_point_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_lsize_orientation_painter.dart';
import 'package:mapiah/src/painters/types/mp_lsize_orientation_info.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/widgets/auxiliary/th_line_painter_line_info.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPLineEditWidget extends StatelessWidget with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final TH2FileEditSelectionController selectionController;
  final TH2FileEditElementEditController elementEditController;
  final MPVisualController visualController;
  final THFile thFile;

  MPLineEditWidget({required this.th2FileEditController, required super.key})
    : selectionController = th2FileEditController.selectionController,
      elementEditController = th2FileEditController.elementEditController,
      visualController = th2FileEditController.visualController,
      thFile = th2FileEditController.thFile;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerAllElements;
        th2FileEditController.redrawTriggerEditLine;
        elementEditController.linePointLSize;
        elementEditController.linePointOrientation;

        final Iterable<MPSelectedElement> logicalSelectedElements =
            selectionController.mpSelectedElementsLogical.values;

        if ((logicalSelectedElements.length != 1) ||
            (logicalSelectedElements.first is! MPSelectedLine)) {
          return SizedBox.shrink();
        }

        final THPointPaint selectedEndPointPaint = visualController
            .getSelectedEndPointPaint();
        final THPointPaint unselectedStraightEndPointPaint = visualController
            .getUnselectedStraightEndPointPaint();
        final THPointPaint unselectedBezierCurveEndPointPaint = visualController
            .getUnselectedBezierCurveEndPointPaint();
        final THPointPaint unselectedControlPointPaint = visualController
            .getUnselectedControlPointPaint();
        final THPointPaint selectedControlPointPaint = visualController
            .getSelectedControlPointPaint();
        final Paint controlPointLinePaint = visualController
            .getControlPointLinePaint();
        final THLinePaint linePaint = visualController.getEditLinePaint();
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
            (logicalSelectedElements.first.originalElementClone as THLine)
              ..setTHFile(thFile);
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
          showLineDirectionTicks: true,
          showMarksOnLineSegments: true,
          showSizeOrientationOnLineSegments: true,
          th2FileEditController: th2FileEditController,
        );
        final bool settingLSizeOrientation =
            ((elementEditController.currentOptionTypeBeingEdited ==
                    THCommandOptionType.orientation) ||
                (elementEditController.currentOptionTypeBeingEdited ==
                    THCommandOptionType.lSize)) &&
            (elementEditController.linePointLSize != null) &&
            (elementEditController.linePointOrientation != null);
        final Map<int, MPLineSegmentSizeOrientationInfo>
        lineSegmentsWithSizeOrientation =
            lineInfo.lineSegmentsWithLSizeOrientation;
        final bool lSizeOrientationExists =
            settingLSizeOrientation ||
            (lineInfo.showSizeOrientationOnLineSegments &&
                lineSegmentsWithSizeOrientation.isNotEmpty);

        if (!settingLSizeOrientation) {
          th2FileEditController.userInteractionController.clearCompassPath();
        }

        CustomPainter painter = THLinePainter(
          lineInfo: lineInfo,
          lineSegmentsMap: segmentsMap,
          linePaint: linePaint,
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

              /// End points should only be painted as selected when end points
              /// are being selected. If there is a control point selected, it
              /// takes precedence.
              final THPointPaint pointPaint;
              final bool noControlPointSelected =
                  (selectedControlPoint == null);
              final bool lineSegmentSelected = selectionController
                  .getIsLineSegmentSelected(lineSegment);

              if (noControlPointSelected && lineSegmentSelected) {
                pointPaint = selectedEndPointPaint;

                if (settingLSizeOrientation) {
                  painters.add(
                    THLSizeOrientationPainter(
                      lSizeOrientationInfo: MPLSizeOrientationInfo(
                        offset: point.position,
                        lSize: elementEditController.linePointLSize!,
                        orientation:
                            elementEditController.linePointOrientation!,
                      ),
                      th2FileEditController: th2FileEditController,
                      storeCompassPath: true,
                    ),
                  );
                }
              } else {
                if (lSizeOrientationExists &&
                    lineSegmentsWithSizeOrientation.containsKey(
                      lineSegment.mpID,
                    )) {
                  final MPLineSegmentSizeOrientationInfo sizeOrientationInfo =
                      lineSegmentsWithSizeOrientation[lineSegment.mpID]!;

                  painters.add(
                    THLSizeOrientationPainter(
                      lSizeOrientationInfo: MPLSizeOrientationInfo(
                        offset: point.position,
                        lSize: sizeOrientationInfo.lSize,
                        orientation: sizeOrientationInfo.orientation,
                      ),
                      th2FileEditController: th2FileEditController,
                    ),
                  );
                }

                if (lineSegment is THStraightLineSegment) {
                  pointPaint = unselectedStraightEndPointPaint;
                } else {
                  pointPaint = unselectedBezierCurveEndPointPaint;
                }
              }

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
