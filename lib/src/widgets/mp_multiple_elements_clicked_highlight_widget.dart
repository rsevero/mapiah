import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/aux/th_line_paint.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_line_painter_line_segment.dart';
import 'package:mapiah/src/painters/th_circle_point_painter.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/widgets/mixins/mp_get_line_segments_map_mixin.dart';

class MPMultipleElementsClickedHighlightWidget extends StatelessWidget
    with MPGetLineSegmentsMapMixin {
  final TH2FileEditController th2FileEditController;
  final THFile thFile;

  MPMultipleElementsClickedHighlightWidget({
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
          final int? highlightedMPID =
              selectionController.multipleElementsClickedHighlightedMPID;

          if (highlightedMPID == null) {
            return const SizedBox.shrink();
          }

          final List<THElement> highlightedElements = (highlightedMPID == 0)
              ? selectionController.clickedElements
              : [thFile.elementByMPID(highlightedMPID)];

          final List<CustomPainter> painters = [];

          final THPointPaint pointPaintInfo =
              th2FileEditController.visualController.getSelectedPointPaint();
          final double pointRadius = pointPaintInfo.radius;

          final THLinePaint borderPaintInfo = th2FileEditController
              .visualController
              .getMultipleElementsClickedHighlightedBorderPaint();
          final Paint borderPaint = borderPaintInfo.paint;
          final THLinePaint fillPaintInfo = th2FileEditController
              .visualController
              .getMultipleElementsClickedHighlightedFillPaint();
          final Paint fillPaint = fillPaintInfo.paint;

          final double canvasScale = th2FileEditController.canvasScale;
          final Offset canvasTranslation =
              th2FileEditController.canvasTranslation;

          for (final highlightedElement in highlightedElements) {
            switch (highlightedElement) {
              case THPoint _:
                painters.add(
                  THCirclePointPainter(
                    position: highlightedElement.position.coordinates,
                    pointRadius: pointRadius,
                    pointPaint: borderPaint,
                    th2FileEditController: th2FileEditController,
                    canvasScale: canvasScale,
                    canvasTranslation: canvasTranslation,
                  ),
                );
              case THLine _:
                final (
                  LinkedHashMap<int, THLinePainterLineSegment> segmentsMap,
                  _
                ) = getLineSegmentsAndEndpointsMaps(
                  line: highlightedElement,
                  thFile: thFile,
                  returnLineSegments: false,
                );

                painters.add(
                  THLinePainter(
                    lineSegmentsMap: segmentsMap,
                    linePaintStroke: borderPaint,
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
