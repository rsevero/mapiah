import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/painters/mp_compass_painter.dart';
import 'package:mapiah/src/painters/types/mp_lsize_orientation_info.dart';

class THLSizeOrientationPainter extends CustomPainter {
  final MPLSizeOrientationInfo lSizeOrientationInfo;
  final TH2FileEditController th2FileEditController;

  THLSizeOrientationPainter({
    super.repaint,
    required this.lSizeOrientationInfo,
    required this.th2FileEditController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double markerScreenSize = lSizeOrientationInfo.lSize;
    final double markerCanvasSize = th2FileEditController.scaleScreenToCanvas(
      markerScreenSize,
    );
    final double azimuth = lSizeOrientationInfo.orientation;
    final double compassDiameter = markerCanvasSize * 8.0;
    final MPCompassPainter compassPainter = MPCompassPainter(
      azimuth: azimuth,
      arrowLength: markerCanvasSize,
      drawBackgroundLines: false,
      th2FileEditController: th2FileEditController,
    );

    canvas.save();

    final double translation = compassDiameter / 2.0;

    canvas.translate(
      lSizeOrientationInfo.offset.dx - translation,
      lSizeOrientationInfo.offset.dy - translation,
    );
    compassPainter.paint(canvas, Size(compassDiameter, compassDiameter));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant THLSizeOrientationPainter oldDelegate) {
    return lSizeOrientationInfo != oldDelegate.lSizeOrientationInfo ||
        th2FileEditController != oldDelegate.th2FileEditController;
  }
}
