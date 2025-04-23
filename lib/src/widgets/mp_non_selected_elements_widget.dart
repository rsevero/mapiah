import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/aux/th_line_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_circle_point_painter.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPNonSelectedElementsWidget extends StatelessWidget
    with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final TH2FileEditSelectionController selectionController;
  final THFile thFile;

  MPNonSelectedElementsWidget({
    required super.key,
    required this.th2FileEditController,
  })  : selectionController = th2FileEditController.selectionController,
        thFile = th2FileEditController.thFile;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNonSelectedElements;
        th2FileEditController.redrawTriggerSelectedElementsListChanged;

        final MPVisualController visualController =
            th2FileEditController.visualController;
        final List<CustomPainter> painters = [];
        final Set<int> drawableElementMPIDs = thFile.drawableElementMPIDs;
        final double canvasScale = th2FileEditController.canvasScale;
        final Offset canvasTranslation =
            th2FileEditController.canvasTranslation;

        for (final int drawableElementMPID in drawableElementMPIDs) {
          if (selectionController.isElementSelectedByMPID(
            drawableElementMPID,
          )) {
            continue;
          }

          final THElement element = thFile.elementByMPID(drawableElementMPID);

          switch (element) {
            case THPoint _:
              final THPointPaint pointPaint =
                  visualController.getUnselectedPointPaint(element);

              painters.add(
                THCirclePointPainter(
                  position: element.position.coordinates,
                  pointRadius: pointPaint.radius,
                  pointBorderPaint: pointPaint.paint,
                  th2FileEditController: th2FileEditController,
                  canvasScale: canvasScale,
                  canvasTranslation: canvasTranslation,
                ),
              );
            case THLine _:
              final int? areaMPID = thFile.getAreaMPIDByLineMPID(element.mpID);
              late final THLinePaint linePaint;

              if (areaMPID == null) {
                linePaint = visualController.getUnselectedLinePaint(element);
              } else {
                if (selectionController.isElementSelectedByMPID(areaMPID)) {
                  continue;
                }

                final THArea area = thFile.areaByMPID(areaMPID);

                linePaint = visualController.getUnselectedAreaBorderPaint(area);
              }

              painters.add(
                getLinePainter(
                  line: element,
                  linePaint: linePaint,
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
      },
    );
  }
}
