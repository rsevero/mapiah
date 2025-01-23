import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/selection/mp_selectable_element.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';

class THPointWidget extends StatelessWidget {
  final THPoint point;
  final double pointRadius;
  final Paint pointPaint;
  final THFileDisplayStore thFileDisplayStore;
  final Size screenSize;

  THPointWidget({
    required this.point,
    required this.pointRadius,
    required this.pointPaint,
    required this.thFileDisplayStore,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    thFileDisplayStore.addSelectableElement(MPSelectableElement(
      element: point,
      position: point.position.coordinates,
    ));

    return CustomPaint(
      painter: THPointPainter(
        position: point.position.coordinates,
        pointRadius: pointRadius,
        pointPaint: pointPaint,
        thFileDisplayStore: thFileDisplayStore,
      ),
      size: screenSize,
    );
  }
}
