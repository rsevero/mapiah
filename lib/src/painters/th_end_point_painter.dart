import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THEndPointPainter extends CustomPainter {
  final Offset position;
  final double halfLength;
  final Paint pointPaint;
  final bool isSmooth;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  THEndPointPainter({
    super.repaint,
    required this.position,
    required this.halfLength,
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
      halfHeight: halfLength,
      halfWidth: halfLength,
    );
    final Rect squareRect = MPNumericAux.orderedRectFromCenterHalfLength(
      center: position,
      halfHeight: halfLength,
      halfWidth: halfLength,
    );

    if (!isSmooth) {
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(th45Degrees);
      canvas.translate(-position.dx, -position.dy);
    }

    canvas.drawRect(whiteRect, THPaints.thPaintWhiteBackground);
    canvas.drawRect(squareRect, pointPaint);

    if (!isSmooth) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant THEndPointPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return position != oldDelegate.position ||
        halfLength != oldDelegate.halfLength ||
        pointPaint != oldDelegate.pointPaint ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation;
  }
}
