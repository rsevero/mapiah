// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/mixins/mp_bounding_box_mixin.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// Paints the transient UI that explains which image is currently being edited.
///
/// This widget does not render the image itself. Instead, it draws an outline
/// around the active image plus a small mode label such as "Move", "Scale", or
/// "Rotate".
///
/// Its role in the image-edit flow is purely communicative:
/// - identify the image currently bound to the image-operation state
/// - show which operation mode is active
/// - follow the live preview offset while the user drags the image
///
/// `IgnorePointer` keeps this overlay from stealing mouse interaction from the
/// canvas, so dragging still reaches the state machine normally.
class MPImageOperationOverlayWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final MPRuntimeImageInsertConfigMixin image;
  final String label;
  final Offset previewOffset;

  const MPImageOperationOverlayWidget({
    super.key,
    required this.th2FileEditController,
    required this.image,
    required this.label,
    required this.previewOffset,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _MPImageOperationOverlayPainter(
          th2FileEditController: th2FileEditController,
          image: image,
          label: label,
          previewOffset: previewOffset,
          colorScheme: Theme.of(context).colorScheme,
        ),
        size: th2FileEditController.screenSize,
      ),
    );
  }
}

/// Internal painter used by [MPImageOperationOverlayWidget].
///
/// The painter reads the image bounding box from the runtime image config,
/// shifts it by the current preview offset, and paints a canvas-space outline
/// plus a badge-like label anchored above the image.
class _MPImageOperationOverlayPainter extends CustomPainter {
  final TH2FileEditController th2FileEditController;
  final MPRuntimeImageInsertConfigMixin image;
  final String label;
  final Offset previewOffset;
  final ColorScheme colorScheme;

  const _MPImageOperationOverlayPainter({
    required this.th2FileEditController,
    required this.image,
    required this.label,
    required this.previewOffset,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect? imageBoundingBox = (image as MPBoundingBoxMixin).getBoundingBox(
      th2FileEditController,
    );

    if (imageBoundingBox == null) {
      return;
    }

    final Rect adjustedBoundingBox = imageBoundingBox.shift(previewOffset);
    final Paint borderPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 / th2FileEditController.canvasScale;
    final double padding = 6.0 / th2FileEditController.canvasScale;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 12.0 / th2FileEditController.canvasScale,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final Rect labelRect = Rect.fromLTWH(
      adjustedBoundingBox.left,
      adjustedBoundingBox.top - textPainter.height - (padding * 2),
      textPainter.width + (padding * 2),
      textPainter.height + (padding * 2),
    );
    final RRect labelRRect = RRect.fromRectAndRadius(
      labelRect,
      Radius.circular(8.0 / th2FileEditController.canvasScale),
    );
    final Paint labelPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;

    th2FileEditController.transformCanvas(canvas);
    canvas.drawRect(adjustedBoundingBox, borderPaint);
    canvas.drawRRect(labelRRect, labelPaint);
    textPainter.paint(
      canvas,
      Offset(labelRect.left + padding, labelRect.top + padding),
    );
  }

  @override
  bool shouldRepaint(covariant _MPImageOperationOverlayPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.label != label ||
        oldDelegate.previewOffset != previewOffset ||
        oldDelegate.colorScheme != colorScheme;
  }
}
