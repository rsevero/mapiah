// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui' as ui;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/mp_raster_image_painter.dart';

class MPRasterImageWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPRuntimeImageInsertConfigMixin image;

  const MPRasterImageWidget({
    super.key,
    required this.th2FileEditController,
    required this.image,
  });

  @override
  State<MPRasterImageWidget> createState() => _MPRasterImageWidgetState();
}

class _MPRasterImageWidgetState extends State<MPRasterImageWidget> {
  ui.Image? _image;
  late final TH2FileEditController th2FileEditController;

  @override
  void initState() {
    super.initState();

    th2FileEditController = widget.th2FileEditController;

    if (!widget.image.isXVI && widget.image.isVisible) {
      final Future<ui.Image>? rasterImage = _getRasterImageFrameInfo(
        widget.image,
      );

      rasterImage?.then((ui.Image img) {
        if (mounted) {
          setState(() => _image = img);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.image.isXVI || !widget.image.isVisible) {
      return SizedBox.shrink();
    }

    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNonSelectedElements;
        th2FileEditController.redrawTriggerImages;

        /// The Y coordinate is negated because in Therion's coordinate system,
        /// positive Y goes up, while in Flutter's canvas, positive Y goes down.
        final Offset offset = _getRasterOffset(widget.image);

        return _image == null
            ? CircularProgressIndicator()
            : CustomPaint(
                painter: MPRasterImagePainter(
                  uiImage: _image!,
                  offset: offset,
                  th2FileEditController: th2FileEditController,
                  canvasScale: th2FileEditController.canvasScale,
                  canvasTranslation: th2FileEditController.canvasTranslation,
                ),
                size: th2FileEditController.screenSize,
              );
      },
    );
  }

  Future<ui.Image>? _getRasterImageFrameInfo(
    MPRuntimeImageInsertConfigMixin image,
  ) {
    switch (image) {
      case THXTherionImageInsertConfig thImage:
        return thImage.getRasterImageFrameInfo(th2FileEditController);
      case MPRasterImageInsertConfig mpImage:
        return mpImage.getRasterImageFrameInfo(th2FileEditController);
      default:
        return null;
    }
  }

  Offset _getRasterOffset(MPRuntimeImageInsertConfigMixin image) {
    switch (image) {
      case THXTherionImageInsertConfig thImage:
        return Offset(thImage.xx.value, -thImage.yy.value);
      case MPRasterImageInsertConfig mpImage:
        return Offset(mpImage.xx.value, -mpImage.yy.value);
      default:
        return Offset.zero;
    }
  }
}
