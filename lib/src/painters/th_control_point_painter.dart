import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/definitions/mp_definitions.dart';
import 'package:mapiah/src/definitions/mp_paints.dart';

class THControlPointPainter extends CustomPainter {
  final Offset position;
  final double pointRadius;
  final Paint pointPaint;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  THControlPointPainter({
    super.repaint,
    required this.position,
    required this.pointRadius,
    required this.pointPaint,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double whiteCircleRadius = pointRadius * thWhiteBackgroundIncrease;

    canvas.drawCircle(
      position,
      whiteCircleRadius,
      THPaints.thPaintWhiteBackground,
    );

    canvas.drawCircle(
      position,
      pointRadius,
      pointPaint,
    );
  }

  @override
  bool shouldRepaint(covariant THControlPointPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return position != oldDelegate.position ||
        pointRadius != oldDelegate.pointRadius ||
        pointPaint != oldDelegate.pointPaint ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation;
  }
}
