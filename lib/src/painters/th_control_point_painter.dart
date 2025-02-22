import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/definitions/mp_paints.dart';

class THControlPointPainter extends CustomPainter {
  final Offset controlPointPosition;
  final Offset endPointPosition;
  final double pointRadius;
  final double expandedPointRadius;
  final Paint pointPaint;
  final Paint controlLinePaint;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  THControlPointPainter({
    super.repaint,
    required this.controlPointPosition,
    required this.endPointPosition,
    required this.pointRadius,
    required this.expandedPointRadius,
    required this.pointPaint,
    required this.controlLinePaint,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(controlPointPosition, endPointPosition, controlLinePaint);

    canvas.drawCircle(
      controlPointPosition,
      expandedPointRadius,
      THPaints.thPaintWhiteBackground,
    );

    canvas.drawCircle(
      controlPointPosition,
      pointRadius,
      pointPaint,
    );
  }

  @override
  bool shouldRepaint(covariant THControlPointPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return controlPointPosition != oldDelegate.controlPointPosition ||
        pointRadius != oldDelegate.pointRadius ||
        expandedPointRadius != oldDelegate.expandedPointRadius ||
        pointPaint != oldDelegate.pointPaint ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation;
  }
}
