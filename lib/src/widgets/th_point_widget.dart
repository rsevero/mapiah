import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/selection/mp_selectable_element.dart';
import 'package:mapiah/src/stores/th_file_edit_store.dart';

class THPointWidget extends StatelessWidget {
  final int pointMapiahID;
  final THFileEditStore thFileEditStore;
  final int thFileMapiahID;
  final int thScrapMapiahID;

  THPointWidget({
    required super.key,
    required this.pointMapiahID,
    required this.thFileEditStore,
    required this.thFileMapiahID,
    required this.thScrapMapiahID,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Observer(
        builder: (_) {
          final THPoint point = thFileEditStore.thFile
              .elementByMapiahID(pointMapiahID) as THPoint;
          thFileEditStore.addSelectableElement(MPSelectableElement(
            element: point,
            position: point.position.coordinates,
          ));

          thFileEditStore.elementRedrawTrigger[thFileMapiahID]!.value;
          thFileEditStore.elementRedrawTrigger[thScrapMapiahID]!.value;
          thFileEditStore.elementRedrawTrigger[pointMapiahID]!.value;

          getIt<MPLog>().fine('THPointWidget for point $pointMapiahID build');

          final THPointPaint pointPaint = thFileEditStore.getPointPaint(point);

          return CustomPaint(
            painter: THPointPainter(
              position: point.position.coordinates,
              pointRadius: pointPaint.radius,
              pointPaint: pointPaint.paint,
              thFileEditStore: thFileEditStore,
            ),
            size: thFileEditStore.screenSize,
          );
        },
      ),
    );
  }
}
