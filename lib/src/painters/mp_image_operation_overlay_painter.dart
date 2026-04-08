// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_image_transform_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// Paints the visual overlay for the image currently in image edit mode.
///
/// The overlay is painted in screen coordinates so the scale arrows remain the
/// same size regardless of zoom level.
class MPImageOperationOverlayPainter extends CustomPainter {
  final TH2FileEditController th2FileEditController;
  final MPRuntimeImageInsertConfigMixin image;
  final Offset hoverScreenPosition;

  const MPImageOperationOverlayPainter({
    required this.th2FileEditController,
    required this.image,
    required this.hoverScreenPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final MPImageTransformGeometry? geometry =
        MPImageTransformGeometry.forImage(
          th2FileEditController: th2FileEditController,
          image: image,
        );

    if (geometry == null) {
      return;
    }

    final MPImageTransformHandleType? hoveredHandle = geometry.hitTestHandle(
      hoverScreenPosition,
    );
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

  @override
  bool shouldRepaint(covariant MPImageOperationOverlayPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.hoverScreenPosition != hoverScreenPosition;
  }
}
