// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/mp_svg_image_painter.dart';

class MPSVGImageWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPSVGImageInsertConfig image;

  const MPSVGImageWidget({
    super.key,
    required this.th2FileEditController,
    required this.image,
  });

  @override
  State<MPSVGImageWidget> createState() => _MPSVGImageWidgetState();
}

class _MPSVGImageWidgetState extends State<MPSVGImageWidget> {
  svg.PictureInfo? _pictureInfo;
  late final TH2FileEditController th2FileEditController;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    _loadPictureInfo();
  }

  @override
  void didUpdateWidget(covariant MPSVGImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.image != widget.image) {
      _loadPictureInfo();
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

        return _pictureInfo == null
            ? CircularProgressIndicator()
            : CustomPaint(
                painter: MPSVGImagePainter(
                  pictureInfo: _pictureInfo!,
                  image: widget.image,
                  th2FileEditController: th2FileEditController,
                  canvasScale: th2FileEditController.canvasScale,
                  canvasTranslation: th2FileEditController.canvasTranslation,
                ),
                size: th2FileEditController.screenSize,
              );
      },
    );
  }

  void _loadPictureInfo() {
    widget.image
        .getSVGPictureInfo(th2FileEditController)
        ?.then((svg.PictureInfo pictureInfo) {
          if (mounted) {
            setState(() {
              _pictureInfo = pictureInfo;
            });
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          mpLocator.mpLog.e(
            'Failed to load SVG image',
            error: error,
            stackTrace: stackTrace,
          );
        });
  }
}
