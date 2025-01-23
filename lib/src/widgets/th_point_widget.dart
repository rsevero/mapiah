import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/selection/mp_selectable_element.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/stores/th_file_store.dart';

class THPointWidget extends StatelessWidget {
  final THPoint point;
  final THFileDisplayStore thFileDisplayStore;
  final THFileStore thFileStore;
  final int thFileMapiahID;
  final int thScrapMapiahID;

  THPointWidget({
    required this.point,
    required this.thFileDisplayStore,
    required this.thFileStore,
    required this.thFileMapiahID,
    required this.thScrapMapiahID,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        thFileDisplayStore.addSelectableElement(MPSelectableElement(
          element: point,
          position: point.position.coordinates,
        ));

        thFileStore.redrawTrigger[thFileMapiahID];
        thFileStore.redrawTrigger[thScrapMapiahID];
        thFileStore.elements[point.mapiahID];

        final THPointPaint pointPaint = thFileDisplayStore.getPointPaint(point);

        return RepaintBoundary(
          child: CustomPaint(
            painter: THPointPainter(
              position: point.position.coordinates,
              pointRadius: pointPaint.radius,
              pointPaint: pointPaint.paint,
              thFileDisplayStore: thFileDisplayStore,
            ),
            size: thFileDisplayStore.screenSize,
          ),
        );
      },
    );
  }
}
