import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/definitions/mp_paints.dart';

class THEndPointPainter extends CustomPainter {
  final Offset position;
  final double width;
  final double expandedWidth;
  final Paint pointPaint;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  THEndPointPainter({
    super.repaint,
    required this.position,
    required this.width,
    required this.expandedWidth,
    required this.pointPaint,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect whiteRect = MPNumericAux.orderedRectFromCenter(
      center: position,
      width: expandedWidth,
      height: expandedWidth,
    );
    final Rect squareRect = MPNumericAux.orderedRectFromCenter(
      center: position,
      width: width,
      height: width,
    );

    canvas.drawRect(whiteRect, THPaints.thPaintWhiteBackground);
    canvas.drawRect(squareRect, pointPaint);
  }

  @override
  bool shouldRepaint(covariant THEndPointPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return position != oldDelegate.position ||
        width != oldDelegate.width ||
        expandedWidth != oldDelegate.expandedWidth ||
        pointPaint != oldDelegate.pointPaint ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation;
  }
}
