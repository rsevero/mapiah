import 'package:flutter/material.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:path_drawing/path_drawing.dart';

class MPSelectionWindowPainter extends CustomPainter {
  final Rect selectionWindowPosition;
  final TH2FileEditStore th2FileEditStore;
  final Paint fillPaint;
  final Paint borderPaint;
  final double dashInterval;
  final double canvasScale;
  final Offset canvasTranslation;

  MPSelectionWindowPainter({
    required this.selectionWindowPosition,
    required this.th2FileEditStore,
    required this.fillPaint,
    required this.borderPaint,
    required this.dashInterval,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    th2FileEditStore.transformCanvas(canvas);

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
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation ||
        fillPaint != oldDelegate.fillPaint ||
        borderPaint != oldDelegate.borderPaint ||
        dashInterval != oldDelegate.dashInterval;
  }
}
