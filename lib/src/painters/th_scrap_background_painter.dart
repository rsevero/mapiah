import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/auxiliary/th_scrap_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THScrapBackgroundPainter extends CustomPainter {
  final Rect backgroundArea;
  final THScrapPaint scrapPaint;
  final TH2FileEditController th2FileEditController;

  THScrapBackgroundPainter({
    super.repaint,
    required this.backgroundArea,
    required this.scrapPaint,
    required this.th2FileEditController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(backgroundArea, scrapPaint.backgroundFill);
  }

  @override
  bool shouldRepaint(covariant THScrapBackgroundPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return backgroundArea != oldDelegate.backgroundArea ||
        scrapPaint != oldDelegate.scrapPaint;
  }
}
