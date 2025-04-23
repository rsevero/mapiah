import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_circle_point_painter.dart';
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

          final THPointPaint pointPaintInfo = th2FileEditController
              .visualController
              .getHighligthtedEndControlPointPaint();
          final Paint pointPaint = pointPaintInfo.paint;
          final double pointRadius = pointPaintInfo.radius;

          final double canvasScale = th2FileEditController.canvasScale;
          final Offset canvasTranslation =
              th2FileEditController.canvasTranslation;

          for (final MPSelectableEndControlPoint highlightedPoint
              in highlightedPoints) {
            switch (highlightedPoint) {
              case MPSelectableControlPoint _:
                painters.add(
                  THCirclePointPainter(
                    position: highlightedPoint.position,
                    pointRadius: pointRadius,
                    pointBorderPaint: pointPaint,
                    th2FileEditController: th2FileEditController,
                    canvasScale: canvasScale,
                    canvasTranslation: canvasTranslation,
                  ),
                );
              case MPSelectableEndPoint _:
                painters.add(
                  THSquarePointPainter(
                    position: highlightedPoint.position,
                    halfLength: pointRadius,
                    pointBorderPaint: pointPaint,
                    rotate: !MPCommandOptionAux.isSmooth(
                        highlightedPoint.element as THHasOptionsMixin),
                    th2FileEditController: th2FileEditController,
                    canvasScale: canvasScale,
                    canvasTranslation: canvasTranslation,
                  ),
                );
            }
          }

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
        }
      },
    );
  }
}
