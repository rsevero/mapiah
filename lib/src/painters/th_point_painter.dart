import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THPointPainter extends CustomPainter {
  final Offset position;
  final THPointPaint pointPaint;
  final TH2FileEditController th2FileEditController;

  THPointPainter({
    super.repaint,
    required this.position,
    required this.pointPaint,
    required this.th2FileEditController,
  }) {
    if ((pointPaint.border == null) && (pointPaint.fill == null)) {
      throw ArgumentError(
        "Both pointPaint.border and pointPaint.fill cannot be null at THCirclePointPainter",
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    MPInteractionAux.drawPoint(
      canvas: canvas,
      position: position,
      pointPaint: pointPaint,
    );
  }

  @override
  bool shouldRepaint(covariant THPointPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return position != oldDelegate.position ||
        pointPaint != oldDelegate.pointPaint;
  }
}
