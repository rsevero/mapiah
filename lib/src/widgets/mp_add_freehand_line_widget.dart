// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/auxiliary/th_point_paint.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_freehand_line_creation_controller.dart';
import 'package:mapiah/src/painters/th_elements_painter.dart';
import 'package:mapiah/src/painters/th_end_point_painter.dart';

/// Live preview of an in-progress freehand line stroke: the raw accepted
/// samples as one continuous polyline, plus the snapped start point.
/// Repaints only when the capture controller signals a new sample, never in
/// response to file-element redraw triggers.
class MPAddFreehandLineWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final TH2FileEditFreehandLineCreationController
  freehandLineCreationController;

  MPAddFreehandLineWidget({required this.th2FileEditController, required super.key})
    : freehandLineCreationController =
          th2FileEditController.freehandLineCreationController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerFreehandLine;

        final List<Offset> sampledCanvasPoints = List<Offset>.of(
          freehandLineCreationController.sampledCanvasPoints,
        );
        final List<CustomPainter> painters = [];

        if (sampledCanvasPoints.isNotEmpty) {
          final MPVisualController visualController =
              th2FileEditController.visualController;
          final THPointPaint startPointPaint = visualController
              .getUnselectedStraightEndPointPaint();

          painters.add(
            THEndPointPainter(
              position: sampledCanvasPoints.first,
              pointPaint: startPointPaint,
              isSmooth: false,
              th2FileEditController: th2FileEditController,
            ),
          );

          if (sampledCanvasPoints.length > 1) {
            final THLinePaint linePaint = visualController.getNewLinePaint();

            painters.add(
              _MPFreehandStrokePainter(
                canvasPoints: sampledCanvasPoints,
                strokePaint: linePaint.primaryPaint!,
              ),
            );
          }
        }

        return RepaintBoundary(
          child: CustomPaint(
            painter: THElementsPainter(
              painters: painters,
              th2FileEditController: th2FileEditController,
            ),
            size: th2FileEditController.screenSize,
          ),
        );
      },
    );
  }
}

class _MPFreehandStrokePainter extends CustomPainter {
  final List<Offset> canvasPoints;
  final Paint strokePaint;

  _MPFreehandStrokePainter({
    required this.canvasPoints,
    required this.strokePaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(canvasPoints.first.dx, canvasPoints.first.dy);

    for (final Offset point in canvasPoints.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _MPFreehandStrokePainter oldDelegate) {
    if (identical(this, oldDelegate)) return false;

    return !listEquals(canvasPoints, oldDelegate.canvasPoints) ||
        (strokePaint != oldDelegate.strokePaint);
  }
}
