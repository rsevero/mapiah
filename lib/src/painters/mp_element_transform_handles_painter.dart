// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_image_transform_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

/// Paints selection handles that match the Inkscape-style arrow handles used
/// for image transform operations.
///
/// In scale mode (the default [SelectNonEmptySelection] state) eight
/// double-arrow handles are drawn at the eight bounding-box positions.
/// In rotate mode ([ElementRotate] state) four curved-arrow handles are drawn
/// at the four corners.
///
/// All rendering is done in screen coordinates so the arrows keep a fixed pixel
/// size regardless of zoom level.
class MPElementTransformHandlesPainter extends CustomPainter {
  final TH2FileEditController th2FileEditController;
  final Rect canvasBoundingBox;
  final Offset hoverScreenPosition;
  final bool isRotateMode;

  const MPElementTransformHandlesPainter({
    required this.th2FileEditController,
    required this.canvasBoundingBox,
    required this.hoverScreenPosition,
    required this.isRotateMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint defaultHandlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final Paint hoveredHandleFillPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;
    final Paint hoveredHandleOutlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (isRotateMode) {
      _paintRotationHandles(
        canvas: canvas,
        defaultHandlePaint: defaultHandlePaint,
        hoveredHandleFillPaint: hoveredHandleFillPaint,
        hoveredHandleOutlinePaint: hoveredHandleOutlinePaint,
      );

      return;
    }

    _paintScaleHandles(
      canvas: canvas,
      defaultHandlePaint: defaultHandlePaint,
      hoveredHandleFillPaint: hoveredHandleFillPaint,
      hoveredHandleOutlinePaint: hoveredHandleOutlinePaint,
    );
  }

  void _paintScaleHandles({
    required Canvas canvas,
    required Paint defaultHandlePaint,
    required Paint hoveredHandleFillPaint,
    required Paint hoveredHandleOutlinePaint,
  }) {
    final MPImageTransformGeometry geometry =
        MPImageTransformGeometry.forCanvasBoundingBox(
          th2FileEditController: th2FileEditController,
          canvasBoundingBox: canvasBoundingBox,
        );

    final MPImageTransformHandleType? hoveredHandle = geometry.hitTestHandle(
      hoverScreenPosition,
    );

    for (final MapEntry<MPImageTransformHandleType, Path> entry
        in geometry.screenHandlePaths.entries) {
      if (entry.key == hoveredHandle) {
        canvas.drawPath(entry.value, hoveredHandleFillPaint);
        canvas.drawPath(entry.value, hoveredHandleOutlinePaint);
      } else {
        canvas.drawPath(entry.value, defaultHandlePaint);
      }
    }
  }

  void _paintRotationHandles({
    required Canvas canvas,
    required Paint defaultHandlePaint,
    required Paint hoveredHandleFillPaint,
    required Paint hoveredHandleOutlinePaint,
  }) {
    final MPImageRotationGeometry geometry =
        MPImageRotationGeometry.forCanvasBoundingBox(
          th2FileEditController: th2FileEditController,
          canvasBoundingBox: canvasBoundingBox,
        );

    final MPImageRotationHandleType? hoveredHandle = geometry.hitTestHandle(
      hoverScreenPosition,
    );

    for (final MapEntry<MPImageRotationHandleType, Path> entry
        in geometry.screenHandlePaths.entries) {
      if (entry.key == hoveredHandle) {
        canvas.drawPath(entry.value, hoveredHandleFillPaint);
        canvas.drawPath(entry.value, hoveredHandleOutlinePaint);
      } else {
        canvas.drawPath(entry.value, defaultHandlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MPElementTransformHandlesPainter oldDelegate) {
    return oldDelegate.canvasBoundingBox != canvasBoundingBox ||
        oldDelegate.hoverScreenPosition != hoverScreenPosition ||
        oldDelegate.isRotateMode != isRotateMode;
  }
}
