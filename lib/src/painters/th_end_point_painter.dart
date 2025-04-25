import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THEndPointPainter extends CustomPainter {
  final Offset position;
  final THPointPaint pointPaint;
  final bool isSmooth;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  THEndPointPainter({
    super.repaint,
    required this.position,
    required this.pointPaint,
    required this.isSmooth,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect whiteRect = MPNumericAux.orderedRectFromCenterHalfLength(
      center: position,
      halfHeight: pointPaint.radius,
      halfWidth: pointPaint.radius,
    );
    final Rect squareRect = MPNumericAux.orderedRectFromCenterHalfLength(
      center: position,
      halfHeight: pointPaint.radius,
      halfWidth: pointPaint.radius,
    );

    if (!isSmooth) {
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(th45Degrees);
      canvas.translate(-position.dx, -position.dy);
    }

    if (pointPaint.fill == null) {
      canvas.drawRect(whiteRect, THPaints.thPaintWhiteBackground);
    } else {
      canvas.drawRect(squareRect, pointPaint.fill!);
    }
    if (pointPaint.border != null) {
      canvas.drawRect(squareRect, pointPaint.border!);
    }

    if (!isSmooth) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant THEndPointPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return position != oldDelegate.position ||
        pointPaint != oldDelegate.pointPaint ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation;
  }
}
