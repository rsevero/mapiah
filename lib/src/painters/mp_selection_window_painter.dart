import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:path_drawing/path_drawing.dart';

class MPSelectionWindowPainter extends CustomPainter {
  final Rect selectionWindowPosition;
  final TH2FileEditController th2FileEditController;
  final Paint fillPaint;
  final Paint borderPaint;
  final double dashInterval;

  MPSelectionWindowPainter({
    required this.selectionWindowPosition,
    required this.th2FileEditController,
    required this.fillPaint,
    required this.borderPaint,
    required this.dashInterval,
  });

  @override
  void paint(Canvas canvas, Size size) {
    th2FileEditController.transformCanvas(canvas);

    Path dashedPath = Path()..addRect(selectionWindowPosition);

    canvas.drawRect(selectionWindowPosition, fillPaint);

    canvas.drawPath(
      dashPath(
        dashedPath,
        dashArray:
            CircularIntervalList<double>(<double>[dashInterval, dashInterval]),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant MPSelectionWindowPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return selectionWindowPosition != oldDelegate.selectionWindowPosition ||
        fillPaint != oldDelegate.fillPaint ||
        borderPaint != oldDelegate.borderPaint ||
        dashInterval != oldDelegate.dashInterval;
  }
}
