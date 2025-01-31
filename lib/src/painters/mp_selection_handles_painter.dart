import 'package:flutter/material.dart';
import 'package:mapiah/src/painters/types/mp_selection_handle_type.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

class MPSelectionHandlesPainter extends CustomPainter {
  final Map<MPSelectionHandleType, Offset> handleCenters;
  final double handleSize;
  final TH2FileEditStore th2FileEditStore;
  final Paint handlePaint;

  MPSelectionHandlesPainter({
    required this.th2FileEditStore,
    required this.handleCenters,
    required this.handleSize,
    required this.handlePaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    th2FileEditStore.transformCanvas(canvas);

    final double halfSize = handleSize / 2;

    Offset center = handleCenters[MPSelectionHandleType.topCenter]!;
    Offset start = Offset(center.dx - halfSize, center.dy);
    Offset end = Offset(center.dx + halfSize, center.dy);
    canvas.drawLine(start, end, handlePaint);

    center = handleCenters[MPSelectionHandleType.bottomCenter]!;
    start = Offset(center.dx - halfSize, center.dy);
    end = Offset(center.dx + halfSize, center.dy);
    canvas.drawLine(start, end, handlePaint);

    center = handleCenters[MPSelectionHandleType.leftCenter]!;
    start = Offset(center.dx, center.dy - halfSize);
    end = Offset(center.dx, center.dy + halfSize);
    canvas.drawLine(start, end, handlePaint);

    center = handleCenters[MPSelectionHandleType.rightCenter]!;
    start = Offset(center.dx, center.dy - halfSize);
    end = Offset(center.dx, center.dy + halfSize);
    canvas.drawLine(start, end, handlePaint);

    center = handleCenters[MPSelectionHandleType.topLeft]!;
    start = Offset(center.dx, center.dy);
    end = Offset(center.dx + handleSize, center.dy);
    canvas.drawLine(start, end, handlePaint);
    start = Offset(center.dx, center.dy);
    end = Offset(center.dx, center.dy + handleSize);
    canvas.drawLine(start, end, handlePaint);

    center = handleCenters[MPSelectionHandleType.topRight]!;
    start = Offset(center.dx, center.dy);
    end = Offset(center.dx - handleSize, center.dy);
    canvas.drawLine(start, end, handlePaint);
    start = Offset(center.dx, center.dy);
    end = Offset(center.dx, center.dy + handleSize);
    canvas.drawLine(start, end, handlePaint);

    center = handleCenters[MPSelectionHandleType.bottomLeft]!;
    start = Offset(center.dx, center.dy);
    end = Offset(center.dx + handleSize, center.dy);
    canvas.drawLine(start, end, handlePaint);
    start = Offset(center.dx, center.dy);
    end = Offset(center.dx, center.dy - handleSize);
    canvas.drawLine(start, end, handlePaint);

    center = handleCenters[MPSelectionHandleType.bottomRight]!;
    start = Offset(center.dx, center.dy);
    end = Offset(center.dx - handleSize, center.dy);
    canvas.drawLine(start, end, handlePaint);
    start = Offset(center.dx, center.dy);
    end = Offset(center.dx, center.dy - handleSize);
    canvas.drawLine(start, end, handlePaint);
  }

  @override
  bool shouldRepaint(covariant MPSelectionHandlesPainter oldDelegate) {
    return true;
  }
}
