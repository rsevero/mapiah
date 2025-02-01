import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/stores/types/th_line_paint.dart';
import 'package:mapiah/src/stores/types/th_point_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:mapiah/src/widgets/mixins/mp_get_line_segments_map_mixin.dart';

class MPNonSelectedElementsWidget extends StatelessWidget
    with MPGetLineSegmentsMapMixin {
  final TH2FileEditStore th2FileEditStore;
  final THFile thFile;

  MPNonSelectedElementsWidget({
    required super.key,
    required this.th2FileEditStore,
  }) : thFile = th2FileEditStore.thFile;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final List<CustomPainter> painters = [];
        final drawableElementMapiahIDs = thFile.drawableElementMapiahIDs;

        th2FileEditStore.redrawTriggerNonSelectedElements;
        th2FileEditStore.redrawTriggerSelectedElementsListChanged;

        for (final drawableElementMapiahID in drawableElementMapiahIDs) {
          final element = thFile.elementByMapiahID(drawableElementMapiahID);

          if (th2FileEditStore.getIsSelected(element)) {
            continue;
          }

          switch (element) {
            case THPoint _:
              final THPointPaint pointPaint =
                  th2FileEditStore.getUnselectedPointPaint(element);
              painters.add(
                THPointPainter(
                  position: element.position.coordinates,
                  pointRadius: pointPaint.radius,
                  pointPaint: pointPaint.paint,
                  th2FileEditStore: th2FileEditStore,
                  canvasScale: th2FileEditStore.canvasScale,
                  canvasTranslation: th2FileEditStore.canvasTranslation,
                ),
              );
              break;
            case THLine _:
              final THLinePaint linePaint =
                  th2FileEditStore.getUnselectedLinePaint(element);
              final segmentsMap = getLineSegmentsMap(element, thFile);
              painters.add(
                THLinePainter(
                  lineSegmentsMap: segmentsMap,
                  linePaint: linePaint.paint,
                  th2FileEditStore: th2FileEditStore,
                  canvasScale: th2FileEditStore.canvasScale,
                  canvasTranslation: th2FileEditStore.canvasTranslation,
                ),
              );
              break;
          }
        }

        return RepaintBoundary(
          child: CustomPaint(
            painter: THElementsPainter(
              painters: painters,
              th2FileEditStore: th2FileEditStore,
              canvasScale: th2FileEditStore.canvasScale,
              canvasTranslation: th2FileEditStore.canvasTranslation,
            ),
            size: th2FileEditStore.screenSize,
          ),
        );
      },
    );
  }
}
