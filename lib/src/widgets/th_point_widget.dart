import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_log.dart';
import 'package:mapiah/src/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/selection/mp_selectable_element.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

class THPointWidget extends StatelessWidget {
  final int pointMapiahID;
  final TH2FileEditStore th2FileEditStore;
  final int thFileMapiahID;
  final int thScrapMapiahID;

  THPointWidget({
    required super.key,
    required this.pointMapiahID,
    required this.th2FileEditStore,
    required this.thFileMapiahID,
    required this.thScrapMapiahID,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Observer(
        builder: (_) {
          final THPoint point = th2FileEditStore.thFile
              .elementByMapiahID(pointMapiahID) as THPoint;
          th2FileEditStore.addSelectableElement(MPSelectableElement(
            element: point,
            position: point.position.coordinates,
          ));

          th2FileEditStore.elementRedrawTrigger[thFileMapiahID]!.value;
          th2FileEditStore.elementRedrawTrigger[thScrapMapiahID]!.value;
          th2FileEditStore.elementRedrawTrigger[pointMapiahID]!.value;

          getIt<MPLog>().fine('THPointWidget for point $pointMapiahID build');

          final THPointPaint pointPaint = th2FileEditStore.getPointPaint(point);

          return CustomPaint(
            painter: THPointPainter(
              position: point.position.coordinates,
              pointRadius: pointPaint.radius,
              pointPaint: pointPaint.paint,
              th2FileEditStore: th2FileEditStore,
            ),
            size: th2FileEditStore.screenSize,
          );
        },
      ),
    );
  }
}
