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
  final bool isRotateMode;

  const MPImageOperationOverlayPainter({
    required this.th2FileEditController,
    required this.image,
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
      _paintRotationOverlay(
        canvas: canvas,
        defaultHandlePaint: defaultHandlePaint,
        hoveredHandleFillPaint: hoveredHandleFillPaint,
        hoveredHandleOutlinePaint: hoveredHandleOutlinePaint,
      );

      return;
    }

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

  void _paintRotationOverlay({
    required Canvas canvas,
    required Paint defaultHandlePaint,
    required Paint hoveredHandleFillPaint,
    required Paint hoveredHandleOutlinePaint,
  }) {
    final MPImageRotationGeometry? geometry = MPImageRotationGeometry.forImage(
      th2FileEditController: th2FileEditController,
      image: image,
    );

    if (geometry == null) {
      return;
    }

    final MPImageRotationHandleType? hoveredHandle = geometry.hitTestHandle(
      hoverScreenPosition,
    );
    final bool isPivotHovered = geometry.hitTestPivot(hoverScreenPosition);
    final bool isPivotDraggable = _isPivotDraggable(image);
    final Paint disabledPivotFillPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final Paint defaultPivotStrokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final Paint disabledPivotStrokePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final MapEntry<MPImageRotationHandleType, Path> entry
        in geometry.screenHandlePaths.entries) {
      if (entry.key == hoveredHandle) {
        canvas.drawPath(entry.value, hoveredHandleFillPaint);
        canvas.drawPath(entry.value, hoveredHandleOutlinePaint);
      } else {
        canvas.drawPath(entry.value, defaultHandlePaint);
      }
    }

    if (!isPivotDraggable) {
      canvas.drawPath(geometry.screenPivotPath, disabledPivotFillPaint);
      canvas.drawPath(geometry.screenPivotPath, disabledPivotStrokePaint);
      return;
    }

    if (isPivotHovered) {
      canvas.drawPath(geometry.screenPivotPath, hoveredHandleFillPaint);
      canvas.drawPath(geometry.screenPivotPath, hoveredHandleOutlinePaint);
    } else {
      canvas.drawPath(geometry.screenPivotPath, defaultHandlePaint);
      canvas.drawPath(geometry.screenPivotPath, defaultPivotStrokePaint);
    }
  }

  bool _isPivotDraggable(MPRuntimeImageInsertConfigMixin runtimeImage) {
    final MPRuntimeXVIImageInsertConfigMixin? xviImage =
        runtimeImage.asXVIImage;

    if (xviImage == null) {
      return true;
    }

    return xviImage.xviRoot.isEmpty;
  }

  @override
  bool shouldRepaint(covariant MPImageOperationOverlayPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.hoverScreenPosition != hoverScreenPosition ||
        oldDelegate.isRotateMode != isRotateMode;
  }
}
