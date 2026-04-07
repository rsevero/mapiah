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
  final MPRuntimeRasterImageInsertConfigMixin image;

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

    if (widget.image.isVisible) {
      final Future<ui.Image>? rasterImage = widget.image
          .getRasterImageFrameInfo(th2FileEditController);

      rasterImage?.then((ui.Image img) {
        if (mounted) {
          setState(() => _image = img);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.image.isVisible) {
      return SizedBox.shrink();
    }

    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNonSelectedElements;
        th2FileEditController.redrawTriggerImages;

        /// The Y coordinate is negated because in Therion's coordinate system,
        /// positive Y goes up, while in Flutter's canvas, positive Y goes down.
        final Offset offset = Offset(
          widget.image.xx.value +
              th2FileEditController.stateController
                  .getImageOperationPreviewOffsetForImage(widget.image.mpID)
                  .dx,
          -(widget.image.yy.value +
              th2FileEditController.stateController
                  .getImageOperationPreviewOffsetForImage(widget.image.mpID)
                  .dy),
        );

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
}
