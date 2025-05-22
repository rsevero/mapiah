import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/painters/th_square_point_painter.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPMultipleEndControlPointsClickedHighlightWidget extends StatelessWidget
    with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final THFile thFile;

  MPMultipleEndControlPointsClickedHighlightWidget({
    required super.key,
    required this.th2FileEditController,
  }) : thFile = th2FileEditController.thFile;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        {
          final TH2FileEditSelectionController selectionController =
              th2FileEditController.selectionController;
          final MPMultipleEndControlPointsClickedChoice highlightedChoice =
              selectionController
                  .multipleEndControlPointsClickedHighlightedChoice;

          if (highlightedChoice.type ==
              MPMultipleEndControlPointsClickedType.none) {
            return const SizedBox.shrink();
          }

          final List<MPSelectableEndControlPoint> highlightedPoints =
              (highlightedChoice.type ==
                      MPMultipleEndControlPointsClickedType.all)
                  ? selectionController.clickedEndControlPoints.toList()
                  : [highlightedChoice.endControlPoint!];

          final List<CustomPainter> painters = [];

          final THPointPaint pointPaint = th2FileEditController.visualController
              .getHighligthtedEndControlPointPaint();

          for (final MPSelectableEndControlPoint highlightedPoint
              in highlightedPoints) {
            switch (highlightedPoint.type) {
              case MPEndControlPointType.controlPoint1:
              case MPEndControlPointType.controlPoint2:
                painters.add(
                  THPointPainter(
                    position: highlightedPoint.position,
                    pointPaint: pointPaint,
                    th2FileEditController: th2FileEditController,
                  ),
                );
              case MPEndControlPointType.endPointBezierCurve:
              case MPEndControlPointType.endPointStraight:
                painters.add(
                  THSquarePointPainter(
                    position: highlightedPoint.position,
                    pointPaint: pointPaint,
                    rotate: !MPCommandOptionAux.isSmooth(
                        highlightedPoint.element as THHasOptionsMixin),
                    th2FileEditController: th2FileEditController,
                  ),
                );
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
        }
      },
    );
  }
}
