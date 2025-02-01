import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

class THElementsPainter extends CustomPainter {
  final List<CustomPainter> painters;
  final TH2FileEditStore th2FileEditStore;
  final double canvasScale;
  final Offset canvasTranslation;

  THElementsPainter({
    required this.painters,
    required this.th2FileEditStore,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    th2FileEditStore.transformCanvas(canvas);

    for (final CustomPainter painter in painters) {
      painter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant THElementsPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return painters.length != oldDelegate.painters.length ||
        canvasScale != oldDelegate.canvasScale ||
        canvasTranslation != oldDelegate.canvasTranslation ||
        !const ListEquality<CustomPainter>()
            .equals(painters, oldDelegate.painters);
  }
}
