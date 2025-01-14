import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/painters/th_point_painter.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';

class THPointWidget extends CustomPaint {
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
  }) : super(
          painter: THPointPainter(
            point: point,
            pointRadius: pointRadius,
            pointPaint: pointPaint,
            thFileDisplayStore: thFileDisplayStore,
          ),
          size: screenSize,
        );
}
