import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class THElementsPainter extends CustomPainter {
  final List<CustomPainter> painters;
  final TH2FileEditController th2FileEditController;

  THElementsPainter({
    required this.painters,
    required this.th2FileEditController,
  });

  @override
  void paint(Canvas canvas, Size size) {
    th2FileEditController.transformCanvas(canvas);

    for (final CustomPainter painter in painters) {
      painter.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant THElementsPainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return painters.length != oldDelegate.painters.length ||
        !const ListEquality<CustomPainter>().equals(
          painters,
          oldDelegate.painters,
        );
  }
}
