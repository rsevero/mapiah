// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_image_transform_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// Paints the visual overlay for the image currently in image edit mode.
///
/// The overlay is painted in screen coordinates so the black handle blocks
/// remain the same size regardless of zoom level.
class MPImageOperationOverlayPainter extends CustomPainter {
  final TH2FileEditController th2FileEditController;
  final MPRuntimeImageInsertConfigMixin image;
  final ColorScheme colorScheme;

  const MPImageOperationOverlayPainter({
    required this.th2FileEditController,
    required this.image,
    required this.colorScheme,
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

    final Paint borderPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = mpImageTransformOverlayBorderWidth;
    final Paint handlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final Path borderPath = Path()
      ..moveTo(
        geometry.screenBorderCorners[0].dx,
        geometry.screenBorderCorners[0].dy,
      )
      ..lineTo(
        geometry.screenBorderCorners[1].dx,
        geometry.screenBorderCorners[1].dy,
      )
      ..lineTo(
        geometry.screenBorderCorners[2].dx,
        geometry.screenBorderCorners[2].dy,
      )
      ..lineTo(
        geometry.screenBorderCorners[3].dx,
        geometry.screenBorderCorners[3].dy,
      )
      ..close();

    canvas.drawPath(borderPath, borderPaint);

    for (final Rect handleRect in geometry.screenHandleRects.values) {
      canvas.drawRect(handleRect, handlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant MPImageOperationOverlayPainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.colorScheme != colorScheme;
  }
}
