import 'package:flutter/material.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

class MPSelectionHandlesPainter extends CustomPainter {
  final List<Rect> handles;
  final TH2FileEditStore th2FileEditStore;
  final Paint fillPaint;

  MPSelectionHandlesPainter({
    required this.th2FileEditStore,
    required this.handles,
    required this.fillPaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    th2FileEditStore.transformCanvas(canvas);

    for (final handle in handles) {
      canvas.drawRect(handle, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
