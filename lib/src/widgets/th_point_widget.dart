import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/selection/mp_selectable_element.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/stores/th_file_store.dart';

class THPointWidget extends StatelessWidget {
  final THPoint point;
  final int pointMapiahID;
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
  }) : pointMapiahID = point.mapiahID;

  @override
  Widget build(BuildContext context) {
    thFileDisplayStore.addSelectableElement(MPSelectableElement(
      element: point,
      position: point.position.coordinates,
    ));

    return RepaintBoundary(
      child: Observer(
        builder: (_) {
          thFileStore.elementRedrawTrigger[thFileMapiahID];
          thFileStore.elementRedrawTrigger[thScrapMapiahID];
          thFileStore.elementRedrawTrigger[pointMapiahID];

          getIt<MPLog>().fine('THPointWidget for point $pointMapiahID build');

          final THPointPaint pointPaint =
              thFileDisplayStore.getPointPaint(point);

          return CustomPaint(
            painter: THPointPainter(
              position: point.position.coordinates,
              pointRadius: pointPaint.radius,
              pointPaint: pointPaint.paint,
              thFileDisplayStore: thFileDisplayStore,
            ),
            size: thFileDisplayStore.screenSize,
          );
        },
      ),
    );
  }
}
