import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_scrap_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/painters/th_scrap_background_painter.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPNonSelectedScrapsWidget extends StatelessWidget
    with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final TH2FileEditSelectionController selectionController;
  final MPVisualController visualController;
  final THFile thFile;

  MPNonSelectedScrapsWidget({
    required super.key,
    required this.th2FileEditController,
  }) : selectionController = th2FileEditController.selectionController,
       visualController = th2FileEditController.visualController,
       thFile = th2FileEditController.thFile;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.activeScrapID;
        th2FileEditController.redrawTriggerAllElements;

        final List<CustomPainter> painters = [];

        addChildrenPainters(
          parent: thFile,
          painters: painters,
          isFromActiveScrap: false,
        );

        return (painters.isEmpty)
            ? SizedBox.shrink()
            : RepaintBoundary(
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

  void addChildrenPainters({
    required THIsParentMixin parent,
    required List<CustomPainter> painters,
    required bool isFromActiveScrap,
    THScrapPaint? parentScrapPaint,
  }) {
    final Iterable<int> drawableChildrenMPIDs = parent
        .getDrawableChildrenMPIDs();

    for (final int drawableChildMPID in drawableChildrenMPIDs) {
      if (isFromActiveScrap &&
          selectionController.isElementSelectedByMPID(drawableChildMPID)) {
        continue;
      }

      final THElement childElement = thFile.elementByMPID(drawableChildMPID);

      switch (childElement) {
        case THPoint point:
          final THPointPaint pointPaint = visualController
              .getUnselectedPointPaint(
                point: point,
                isFromActiveScrap: isFromActiveScrap,
                parentScrapPaint: parentScrapPaint,
              );

          painters.add(
            THPointPainter(
              position: childElement.position.coordinates,
              pointPaint: pointPaint,
              th2FileEditController: th2FileEditController,
            ),
          );
        case THLine line:
          painters.addAll(
            getLinePainters(
              line: line,
              isLineSelected: false,
              showLineDirectionTicks: false,
              isFromActiveScrap: isFromActiveScrap,
              parentScrapPaint: parentScrapPaint,
              th2FileEditController: th2FileEditController,
            ),
          );
        case THScrap scrap:
          if (scrap.mpID == th2FileEditController.activeScrapID) {
            continue;
          }

          final THScrapPaint scrapPaint = visualController.getScrapPaint(scrap);

          painters.add(
            THScrapBackgroundPainter(
              backgroundArea: MPInteractionAux.getScrapBackgroundRect(
                scrap: scrap,
                th2FileEditController: th2FileEditController,
              ),
              scrapPaint: scrapPaint,
              th2FileEditController: th2FileEditController,
            ),
          );

          addChildrenPainters(
            parent: scrap,
            painters: painters,
            isFromActiveScrap: false,
            parentScrapPaint: scrapPaint,
          );
      }
    }
  }
}
