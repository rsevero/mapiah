import 'package:flutter/material.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:path_drawing/path_drawing.dart';

class MPSelectionWindowPainter extends CustomPainter {
  final Rect selectionWindowPosition;
  final TH2FileEditStore th2FileEditStore;

  MPSelectionWindowPainter({
    required this.selectionWindowPosition,
    required this.th2FileEditStore,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectionWindowPosition.isEmpty) {
      return;
    }

    th2FileEditStore.transformCanvas(canvas);

    Paint selectionFillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    Paint selectionBorderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    Path dashedPath = Path()..addRect(selectionWindowPosition);

    canvas.drawRect(selectionWindowPosition, selectionFillPaint);

    canvas.drawPath(
      dashPath(
        dashedPath,
        dashArray: CircularIntervalList<double>(<double>[5, 5]),
      ),
      selectionBorderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
