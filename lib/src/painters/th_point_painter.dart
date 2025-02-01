import 'package:flutter/material.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

class THPointPainter extends CustomPainter {
  final Offset position;
  final double pointRadius;
  final Paint pointPaint;
  final TH2FileEditStore th2FileEditStore;
  final double canvasScale;
  final Offset canvasTranslation;

  THPointPainter({
    super.repaint,
    required this.position,
    required this.pointRadius,
    required this.pointPaint,
    required this.th2FileEditStore,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      position,
      pointRadius,
      pointPaint,
    );
  }

  @override
  bool shouldRepaint(covariant THPointPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return position != oldDelegate.position ||
        pointRadius != oldDelegate.pointRadius ||
        pointPaint != oldDelegate.pointPaint ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation;
  }
}
