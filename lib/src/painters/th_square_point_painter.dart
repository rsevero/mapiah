import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THSquarePointPainter extends CustomPainter {
  final Offset position;
  final double halfLength;
  final Paint? pointBorderPaint;
  final Paint? pointFillPaint;
  final bool rotate;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  THSquarePointPainter({
    super.repaint,
    required this.position,
    required this.halfLength,
    this.pointBorderPaint,
    this.pointFillPaint,
    this.rotate = false,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  }) {
    if ((pointBorderPaint == null) && (pointFillPaint == null)) {
      throw ArgumentError(
          "Both pointBorderPaint and pointFillPaint cannot be null at THSquarePointPainter");
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect squareRect = MPNumericAux.orderedRectFromCenterHalfLength(
      center: position,
      halfHeight: halfLength,
      halfWidth: halfLength,
    );

    if (rotate) {
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(th45Degrees);
      canvas.translate(-position.dx, -position.dy);
    }

    if (pointFillPaint != null) {
      canvas.drawRect(
        squareRect,
        pointFillPaint!,
      );
    }

    if (pointBorderPaint != null) {
      canvas.drawRect(
        squareRect,
        pointBorderPaint!,
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
        halfLength != oldDelegate.halfLength ||
        pointBorderPaint != oldDelegate.pointBorderPaint ||
        pointFillPaint != oldDelegate.pointFillPaint ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation;
  }
}
