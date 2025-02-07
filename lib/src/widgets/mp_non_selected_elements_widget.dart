import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/types/th_line_paint.dart';
import 'package:mapiah/src/controllers/types/th_point_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/widgets/mixins/mp_get_line_segments_map_mixin.dart';

class MPNonSelectedElementsWidget extends StatelessWidget
    with MPGetLineSegmentsMapMixin {
  final TH2FileEditController th2FileEditController;
  final THFile thFile;

  MPNonSelectedElementsWidget({
    required super.key,
    required this.th2FileEditController,
  }) : thFile = th2FileEditController.thFile;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final List<CustomPainter> painters = [];
        final drawableElementMapiahIDs = thFile.drawableElementMapiahIDs;

        th2FileEditController.redrawTriggerNonSelectedElements;
        th2FileEditController.redrawTriggerSelectedElementsListChanged;

        for (final drawableElementMapiahID in drawableElementMapiahIDs) {
          final element = thFile.elementByMapiahID(drawableElementMapiahID);

          if (th2FileEditController.getIsSelected(element)) {
            continue;
          }

          switch (element) {
            case THPoint _:
              final THPointPaint pointPaint =
                  th2FileEditController.getUnselectedPointPaint(element);
              painters.add(
                THPointPainter(
                  position: element.position.coordinates,
                  pointRadius: pointPaint.radius,
                  pointPaint: pointPaint.paint,
                  th2FileEditController: th2FileEditController,
                  canvasScale: th2FileEditController.canvasScale,
                  canvasTranslation: th2FileEditController.canvasTranslation,
                ),
              );
              break;
            case THLine _:
              final THLinePaint linePaint =
                  th2FileEditController.getUnselectedLinePaint(element);
              final segmentsMap = getLineSegmentsMap(element, thFile);
              painters.add(
                THLinePainter(
                  lineSegmentsMap: segmentsMap,
                  linePaint: linePaint.paint,
                  th2FileEditController: th2FileEditController,
                  canvasScale: th2FileEditController.canvasScale,
                  canvasTranslation: th2FileEditController.canvasTranslation,
                ),
              );
              break;
          }
        }

        return RepaintBoundary(
          child: CustomPaint(
            painter: THElementsPainter(
              painters: painters,
              th2FileEditController: th2FileEditController,
              canvasScale: th2FileEditController.canvasScale,
              canvasTranslation: th2FileEditController.canvasTranslation,
            ),
            size: th2FileEditController.screenSize,
          ),
        );
      },
    );
  }
}
