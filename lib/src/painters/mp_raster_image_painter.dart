import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class MPRasterImagePainter extends CustomPainter {
  final ui.Image uiImage;
  final Offset offset;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  MPRasterImagePainter({
    required this.uiImage,
    required this.offset,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    /// Removing the inversion of canvas orientation so images aren´t presented
    /// upside down.
    th2FileEditController.transformCanvas(canvas, invert: false);
    canvas.drawImage(uiImage, offset, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MPRasterImagePainter oldDelegate) {
    return oldDelegate.uiImage != uiImage ||
        oldDelegate.offset != offset ||
        oldDelegate.canvasScale != canvasScale ||
        oldDelegate.canvasTranslation != canvasTranslation;
  }
}
