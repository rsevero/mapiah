import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/aux/th_line_paint.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/th_circle_point_painter.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/widgets/mixins/mp_line_painting_mixin.dart';

class MPMultipleElementsClickedHighlightWidget extends StatelessWidget
    with MPLinePaintingMixin {
  final TH2FileEditController th2FileEditController;
  final THFile thFile;
  final MPVisualController visualController;

  MPMultipleElementsClickedHighlightWidget({
    required super.key,
    required this.th2FileEditController,
  })  : thFile = th2FileEditController.thFile,
        visualController = th2FileEditController.visualController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        {
          final TH2FileEditSelectionController selectionController =
              th2FileEditController.selectionController;
          final int? highlightedMPID =
              selectionController.multipleElementsClickedHighlightedMPID;

          if (highlightedMPID == null) {
            return const SizedBox.shrink();
          }

          final List<THElement> highlightedElements = (highlightedMPID == 0)
              ? selectionController.clickedElements.values.toList()
              : [thFile.elementByMPID(highlightedMPID)];

          final List<CustomPainter> painters = [];

          final THLinePaint areaPaint =
              visualController.getMultipleElementsClickedHighlightedFillPaint();

          for (final highlightedElement in highlightedElements) {
            switch (highlightedElement) {
              case THPoint _:
                final THPointPaint pointPaint =
                    visualController.getSelectedPointPaint(highlightedElement);

                painters.add(
                  THCirclePointPainter(
                    position: highlightedElement.position.coordinates,
                    pointPaint: pointPaint,
                    th2FileEditController: th2FileEditController,
                  ),
                );
              // case THLineSegment _:
              //   final THLineSegment previousLineSegment = thFile
              //       .lineByMPID(highlightedElement.mpID)
              //       .getPreviousLineSegment(highlightedElement, thFile);

              //   painters.add(
              //     THLineSegmentPainter(
              //       previousLineSegment: previousLineSegment,
              //       lineSegment: highlightedElement,
              //       linePaint: linePaint,
              //       th2FileEditController: th2FileEditController,
              //       canvasScale: canvasScale,
              //       canvasTranslation: canvasTranslation,
              //     ),
              //   );
              case THLine _:
                final (
                  LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
                  _
                ) = getLineSegmentsAndEndpointsMaps(
                  line: highlightedElement,
                  thFile: thFile,
                  returnLineSegments: false,
                );
                final THLinePaint linePaint = visualController
                    .getMultipleElementsClickedHighlightedBorderPaint(
                        highlightedElement);

                painters.add(
                  THLinePainter(
                    lineSegmentsMap: segmentsMap,
                    linePaint: linePaint,
                    th2FileEditController: th2FileEditController,
                  ),
                );
              case THArea _:
                final Set<int> areaLineMPIDs =
                    highlightedElement.getLineMPIDs(thFile);

                for (final int lineMPID in areaLineMPIDs) {
                  final THLine highlightedElement = thFile.lineByMPID(lineMPID);
                  final (
                    LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
                    _
                  ) = getLineSegmentsAndEndpointsMaps(
                    line: highlightedElement,
                    thFile: thFile,
                    returnLineSegments: false,
                  );
                  final THLinePainter linePainter = THLinePainter(
                    lineSegmentsMap: segmentsMap,
                    linePaint: areaPaint,
                    th2FileEditController: th2FileEditController,
                  );

                  painters.add(linePainter);
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
        }
      },
    );
  }
}
