import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THCirclePointPainter extends CustomPainter {
  final Offset position;
  final THPointPaint pointPaint;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  THCirclePointPainter({
    super.repaint,
    required this.position,
    required this.pointPaint,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  }) {
    if ((pointPaint.border == null) && (pointPaint.fill == null)) {
      throw ArgumentError(
          "Both pointBorderPaint and pointFillPaint cannot be null at THCirclePointPainter");
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (pointPaint.fill != null) {
      canvas.drawCircle(
        position,
        pointPaint.radius,
        pointPaint.fill!,
      );
    }

    if (pointPaint.border != null) {
      canvas.drawCircle(
        position,
        pointPaint.radius,
        pointPaint.border!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant THCirclePointPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return position != oldDelegate.position ||
        pointPaint != oldDelegate.pointPaint ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation;
  }
}
