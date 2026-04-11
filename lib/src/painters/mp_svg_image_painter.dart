// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

class MPSVGImagePainter extends CustomPainter {
  final svg.PictureInfo pictureInfo;
  final MPSVGImageInsertConfig image;
  final TH2FileEditController th2FileEditController;
  final double canvasScale;
  final Offset canvasTranslation;

  MPSVGImagePainter({
    required this.pictureInfo,
    required this.image,
    required this.th2FileEditController,
    required this.canvasScale,
    required this.canvasTranslation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect sourceViewBox = image.intrinsicSizeInfo.sourceViewBox;
    final Offset topLeft = _localPointToScreen(
      Offset(0.0, -image.intrinsicSizeInfo.height),
    );
    final Offset topRight = _localPointToScreen(
      Offset(image.intrinsicSizeInfo.width, -image.intrinsicSizeInfo.height),
    );
    final Offset bottomLeft = _localPointToScreen(Offset(0.0, 0.0));
    final Offset xAxis = (topRight - topLeft) / sourceViewBox.width;
    final Offset yAxis = (bottomLeft - topLeft) / sourceViewBox.height;
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
    canvas.translate(-sourceViewBox.left, -sourceViewBox.top);
    canvas.translate(0.0, sourceViewBox.height);
    canvas.scale(1.0, -1.0);
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();
  }

  Offset _localPointToScreen(Offset localPoint) {
    final Offset canvasPoint = image.transformLocalPoint(localPoint);

    return th2FileEditController.offsetCanvasToScreen(canvasPoint);
  }

  @override
  bool shouldRepaint(covariant MPSVGImagePainter oldDelegate) {
    return oldDelegate.pictureInfo != pictureInfo ||
        oldDelegate.image != image ||
        oldDelegate.canvasScale != canvasScale ||
        oldDelegate.canvasTranslation != canvasTranslation;
  }
}
