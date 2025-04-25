import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_paints.dart';
import 'package:mapiah/src/controllers/aux/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THControlPointPainter extends CustomPainter {
  final Offset controlPointPosition;
  final Offset endPointPosition;
  final THPointPaint pointPaint;
  final Paint controlLinePaint;
  final TH2FileEditController th2FileEditController;

  THControlPointPainter({
    super.repaint,
    required this.controlPointPosition,
    required this.endPointPosition,
    required this.pointPaint,
    required this.controlLinePaint,
    required this.th2FileEditController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(controlPointPosition, endPointPosition, controlLinePaint);

    if (pointPaint.fill == null) {
      canvas.drawCircle(
        controlPointPosition,
        pointPaint.radius,
        THPaints.thPaintWhiteBackground,
      );
    } else {
      canvas.drawCircle(
        controlPointPosition,
        pointPaint.radius,
        pointPaint.fill!,
      );
    }

    if (pointPaint.border != null) {
      canvas.drawCircle(
          controlPointPosition, pointPaint.radius, pointPaint.border!);
    }
  }

  @override
  bool shouldRepaint(covariant THControlPointPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return controlPointPosition != oldDelegate.controlPointPosition ||
        pointPaint != oldDelegate.pointPaint ||
        endPointPosition != oldDelegate.endPointPosition ||
        controlLinePaint != oldDelegate.controlLinePaint ||
        th2FileEditController != oldDelegate.th2FileEditController;
  }
}
