import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_line_painter.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:mapiah/src/widgets/mp_get_line_segments_map_mixin.dart';

class MPSelectedElementsWidget extends StatelessWidget
    with MPGetLineSegmentsMapMixin {
  final TH2FileEditStore th2FileEditStore;
  final THFile thFile;

  MPSelectedElementsWidget({
    required super.key,
    required this.th2FileEditStore,
  }) : thFile = th2FileEditStore.thFile;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final List<CustomPainter> painters = [];
        final selectedElements = th2FileEditStore.selectedElements.values;

        th2FileEditStore.redrawTriggerSelectedElements;
        th2FileEditStore.redrawTriggerSelectedElementsListChanged;

        final THPointPaint pointPaintInfo =
            th2FileEditStore.getSelectedPointPaint();
        final double pointRadius = pointPaintInfo.radius;
        final Paint pointPaint = pointPaintInfo.paint;

        final THLinePaint linePaintInfo =
            th2FileEditStore.getSelectedLinePaint();
        final Paint linePaint = linePaintInfo.paint;

        for (final selectedElement in selectedElements) {
          final THElement element =
              thFile.elementByMapiahID(selectedElement.mapiahID);

          switch (element) {
            case THPoint _:
              painters.add(
                THPointPainter(
                    position: element.position.coordinates,
                    pointRadius: pointRadius,
                    pointPaint: pointPaint,
                    th2FileEditStore: th2FileEditStore),
              );
              break;
            case THLine _:
              final segmentsMap = getLineSegmentsMap(element, thFile);
              painters.add(
                THLinePainter(
                  lineSegmentsMap: segmentsMap,
                  linePaint: linePaint,
                  th2FileEditStore: th2FileEditStore,
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
            ),
            size: th2FileEditStore.screenSize,
          ),
        );
      },
    );
  }
}
