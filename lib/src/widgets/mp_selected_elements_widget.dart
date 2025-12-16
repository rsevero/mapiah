import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPSelectedElementsWidget extends StatelessWidget
    with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final THFile thFile;
  final MPVisualController visualController;

  MPSelectedElementsWidget({
    required super.key,
    required this.th2FileEditController,
  }) : thFile = th2FileEditController.thFile,
       visualController = th2FileEditController.visualController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerSelectedElements;
        th2FileEditController.redrawTriggerSelectedElementsListChanged;

        final List<CustomPainter> painters = [];
        final Iterable<MPSelectedElement> mpSelectedElements =
            th2FileEditController
                .selectionController
                .mpSelectedElementsLogical
                .values;

        for (final mpSelectedElement in mpSelectedElements) {
          final THElement element = thFile.elementByMPID(
            mpSelectedElement.mpID,
          );

          switch (element) {
            case THPoint _:
              final THPointPaint pointPaint = visualController
                  .getSelectedPointPaint(element);

              painters.add(
                THPointPainter(
                  position: element.position.coordinates,
                  pointPaint: pointPaint,
                  th2FileEditController: th2FileEditController,
                ),
              );
            case THLine _:
              painters.add(
                getLinePainter(
                  line: element,
                  isLineSelected: true,
                  showLineDirectionTicks: true,
                  th2FileEditController: th2FileEditController,
                ),
              );
            case THArea _:
              final List<int> areaLineMPIDs = element.getLineMPIDs(thFile);

              for (final int areaLineMPID in areaLineMPIDs) {
                final THLine line = thFile.lineByMPID(areaLineMPID);

                painters.add(
                  getLinePainter(
                    line: line,
                    isLineSelected: true,
                    showLineDirectionTicks: false,
                    th2FileEditController: th2FileEditController,
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
            ),
            size: th2FileEditController.screenSize,
          ),
        );
      },
    );
  }
}
