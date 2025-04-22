import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/aux/th_line_paint.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_circle_point_painter.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPSelectedElementsWidget extends StatelessWidget
    with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final THFile thFile;

  MPSelectedElementsWidget({
    required super.key,
    required this.th2FileEditController,
  }) : thFile = th2FileEditController.thFile;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerSelectedElements;
        th2FileEditController.redrawTriggerSelectedElementsListChanged;

        final List<CustomPainter> painters = [];
        final mpSelectedElements = th2FileEditController
            .selectionController.mpSelectedElementsLogical.values;

        final THPointPaint pointPaintInfo =
            th2FileEditController.visualController.getSelectedPointPaint();
        final double pointRadius = pointPaintInfo.radius;
        final Paint pointPaint = pointPaintInfo.paint;

        final THLinePaint linePaintInfo =
            th2FileEditController.visualController.getSelectedLinePaint();
        final Paint linePaint = linePaintInfo.paint;

        final Paint fillPaint = th2FileEditController.visualController
            .getSelectedAreaFillPaint()
            .paint;
        final Paint borderPaint = th2FileEditController.visualController
            .getSelectedAreaBorderPaint()
            .paint;

        final double canvasScale = th2FileEditController.canvasScale;
        final Offset canvasTranslation =
            th2FileEditController.canvasTranslation;

        for (final mpSelectedElement in mpSelectedElements) {
          final THElement element =
              thFile.elementByMPID(mpSelectedElement.mpID);

          switch (element) {
            case THPoint _:
              painters.add(
                THCirclePointPainter(
                  position: element.position.coordinates,
                  pointRadius: pointRadius,
                  pointBorderPaint: pointPaint,
                  th2FileEditController: th2FileEditController,
                  canvasScale: canvasScale,
                  canvasTranslation: canvasTranslation,
                ),
              );
            case THLine _:
              painters.add(
                getLinePainter(
                  line: element,
                  linePaint: linePaint,
                  th2FileEditController: th2FileEditController,
                  canvasScale: canvasScale,
                  canvasTranslation: canvasTranslation,
                ),
              );
            case THArea _:
              final Set<int> areaLineMPIDs = element.getLineMPIDs(thFile);

              for (final int areaLineMPID in areaLineMPIDs) {
                final THLine line = thFile.lineByMPID(areaLineMPID);

                painters.add(
                  getLinePainter(
                    line: line,
                    linePaint: borderPaint,
                    fillPaint: fillPaint,
                    th2FileEditController: th2FileEditController,
                    canvasScale: canvasScale,
                    canvasTranslation: canvasTranslation,
                  ),
                );
              }
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
      },
    );
  }
}
