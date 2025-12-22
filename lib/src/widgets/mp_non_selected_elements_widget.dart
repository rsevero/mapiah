import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPNonSelectedElementsWidget extends StatelessWidget
    with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final TH2FileEditSelectionController selectionController;
  final MPVisualController visualController;
  final THFile thFile;
  final int activeScrapMPID;

  MPNonSelectedElementsWidget({
    required super.key,
    required this.th2FileEditController,
  }) : selectionController = th2FileEditController.selectionController,
       visualController = th2FileEditController.visualController,
       thFile = th2FileEditController.thFile,
       activeScrapMPID = th2FileEditController.activeScrapID;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNonSelectedElements;
        th2FileEditController.redrawTriggerSelectedElementsListChanged;

        final List<CustomPainter> painters = [];

        addChildrenPainters(parent: thFile, painters: painters);
        addChildrenPainters(
          parent: thFile.scrapByMPID(activeScrapMPID),
          painters: painters,
          isFromSelectedScrap: true,
        );

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

  void addChildrenPainters({
    required THIsParentMixin parent,
    required List<CustomPainter> painters,
    bool isFromSelectedScrap = false,
  }) {
    final Iterable<int> childrenMPIDs = parent.childrenMPIDs;

    for (final int childMPID in childrenMPIDs) {
      if (isFromSelectedScrap &&
          selectionController.isElementSelectedByMPID(childMPID)) {
        continue;
      }

      final THElement childElement = thFile.elementByMPID(childMPID);

      switch (childElement) {
        case THPoint point:
          final THPointPaint pointPaint = visualController
              .getUnselectedPointPaint(point);

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
              th2FileEditController: th2FileEditController,
            ),
          );
        case THScrap scrap:
          if (scrap.mpID == activeScrapMPID) {
            continue;
          }

          addChildrenPainters(parent: scrap, painters: painters);
      }
    }
  }
}
