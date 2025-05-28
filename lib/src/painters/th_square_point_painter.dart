import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THSquarePointPainter extends CustomPainter {
  final Offset position;
  final THPointPaint pointPaint;
  final bool rotate;
  final TH2FileEditController th2FileEditController;

  THSquarePointPainter({
    super.repaint,
    required this.position,
    required this.pointPaint,
    this.rotate = false,
    required this.th2FileEditController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect squareRect = MPNumericAux.orderedRectFromCenterHalfLength(
      center: position,
      halfHeight: pointPaint.radius,
      halfWidth: pointPaint.radius,
    );

    if (rotate) {
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(th45Degrees);
      canvas.translate(-position.dx, -position.dy);
    }

    if (pointPaint.fill != null) {
      canvas.drawRect(
        squareRect,
        pointPaint.fill!,
      );
    }

    if (pointPaint.border != null) {
      canvas.drawRect(
        squareRect,
        pointPaint.border!,
      );
    }

    if (rotate) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant THSquarePointPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return position != oldDelegate.position ||
        pointPaint != oldDelegate.pointPaint ||
        rotate != oldDelegate.rotate;
  }
}
