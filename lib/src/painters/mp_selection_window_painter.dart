import 'package:flutter/material.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:path_drawing/path_drawing.dart';

class MPSelectionWindowPainter extends CustomPainter {
  final Rect selectionWindowPosition;
  final TH2FileEditStore th2FileEditStore;
  final Paint fillPaint;
  final Paint borderPaint;

  MPSelectionWindowPainter({
    required this.selectionWindowPosition,
    required this.th2FileEditStore,
    required this.fillPaint,
    required this.borderPaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectionWindowPosition.isEmpty) {
      return;
    }

    th2FileEditStore.transformCanvas(canvas);

    Path dashedPath = Path()..addRect(selectionWindowPosition);

    canvas.drawRect(selectionWindowPosition, fillPaint);

    canvas.drawPath(
      dashPath(
        dashedPath,
        dashArray: CircularIntervalList<double>(<double>[5, 5]),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
