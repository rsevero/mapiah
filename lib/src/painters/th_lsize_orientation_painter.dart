import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/painters/mp_compass_painter.dart';
import 'package:mapiah/src/painters/types/mp_lsize_orientation_info.dart';

class THLSizeOrientationPainter extends CustomPainter {
  static const double _compassDiameterFactor = 8.0;

  final MPLSizeOrientationInfo lSizeOrientationInfo;
  final TH2FileEditController th2FileEditController;
  final bool storeCompassPath;

  THLSizeOrientationPainter({
    super.repaint,
    required this.lSizeOrientationInfo,
    required this.th2FileEditController,
    this.storeCompassPath = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double markerCanvasSize = compassMarkerCanvasSize(
      lSizeOnScreen: lSizeOrientationInfo.lSize,
      th2FileEditController: th2FileEditController,
    );
    final double azimuth = lSizeOrientationInfo.orientation;
    final double compassDiameter = markerCanvasSize * _compassDiameterFactor;

    canvas.save();

    final double translation = compassDiameter / 2.0;
    final Offset compassOffset = Offset(
      lSizeOrientationInfo.offset.dx - translation,
      lSizeOrientationInfo.offset.dy - translation,
    );

    canvas.translate(compassOffset.dx, compassOffset.dy);

    final MPCompassPainter configuredCompassPainter = MPCompassPainter(
      azimuth: azimuth,
      arrowLength: markerCanvasSize,
      drawBackgroundLines: false,
      userInteractionController: storeCompassPath
          ? th2FileEditController.userInteractionController
          : null,
      canvasOffset: compassOffset,
    );

    configuredCompassPainter.paint(
      canvas,
      Size(compassDiameter, compassDiameter),
    );
    canvas.restore();
  }

  static double compassMarkerCanvasSize({
    required double lSizeOnScreen,
    required TH2FileEditController th2FileEditController,
  }) {
    return th2FileEditController.scaleScreenToCanvas(lSizeOnScreen);
  }

  static double compassRadiusCanvasSize({
    required double lSizeOnScreen,
    required TH2FileEditController th2FileEditController,
  }) {
    return compassMarkerCanvasSize(
          lSizeOnScreen: lSizeOnScreen,
          th2FileEditController: th2FileEditController,
        ) *
        (_compassDiameterFactor / 2.0);
  }

  @override
  bool shouldRepaint(covariant THLSizeOrientationPainter oldDelegate) {
    return lSizeOrientationInfo != oldDelegate.lSizeOrientationInfo ||
        th2FileEditController != oldDelegate.th2FileEditController;
  }
}
