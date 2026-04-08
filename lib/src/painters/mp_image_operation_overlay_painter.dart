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

  const MPImageOperationOverlayPainter({
    required this.th2FileEditController,
    required this.image,
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

    final Paint handlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    for (final Path handlePath in geometry.screenHandlePaths.values) {
      canvas.drawPath(handlePath, handlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant MPImageOperationOverlayPainter oldDelegate) {
    return oldDelegate.image != image;
  }
}
