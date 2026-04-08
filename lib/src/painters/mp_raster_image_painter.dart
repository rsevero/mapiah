// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

class MPRasterImagePainter extends CustomPainter {
  final ui.Image uiImage;
  final MPRuntimeRasterImageInsertConfigMixin image;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  MPRasterImagePainter({
    required this.uiImage,
    required this.image,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset topLeft = _imagePointToScreen(Offset.zero);
    final Offset topRight = _imagePointToScreen(
      Offset(uiImage.width.toDouble(), 0.0),
    );
    final Offset bottomLeft = _imagePointToScreen(
      Offset(0.0, uiImage.height.toDouble()),
    );
    final Offset xAxis = (topRight - topLeft) / uiImage.width.toDouble();
    final Offset yAxis = (bottomLeft - topLeft) / uiImage.height.toDouble();
    final Float64List matrix = Float64List.fromList(<double>[
      xAxis.dx,
      xAxis.dy,
      0.0,
      0.0,
      yAxis.dx,
      yAxis.dy,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      topLeft.dx,
      topLeft.dy,
      0.0,
      1.0,
    ]);

    canvas.save();
    canvas.transform(matrix);
    canvas.drawImage(uiImage, Offset.zero, Paint());
    canvas.restore();
  }

  Offset _imagePointToScreen(Offset imagePoint) {
    final Offset canvasPoint = _imagePointToCanvas(imagePoint);

    return th2FileEditController.offsetCanvasToScreen(canvasPoint);
  }

  Offset _imagePointToCanvas(Offset imagePoint) {
    final Offset baseWorldPoint = Offset(
      image.xx.value + imagePoint.dx,
      image.yy.value - uiImage.height.toDouble() + imagePoint.dy,
    );

    return image.transformWorldPointFromBaseWorldPoint(baseWorldPoint);
  }

  @override
  bool shouldRepaint(covariant MPRasterImagePainter oldDelegate) {
    return oldDelegate.uiImage != uiImage ||
        oldDelegate.image != image ||
        oldDelegate.canvasScale != canvasScale ||
        oldDelegate.canvasTranslation != canvasTranslation;
  }
}
