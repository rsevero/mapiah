// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/mp_image_operation_overlay_widget.dart';
import 'package:mapiah/src/widgets/mp_raster_image_widget.dart';
import 'package:mapiah/src/widgets/mp_xvi_image_widget.dart';

class MPImagesWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  const MPImagesWidget({super.key, required this.th2FileEditController});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerAllElements;
        th2FileEditController.redrawTriggerImages;

        final List<Widget> widgets = [];
        final Iterable<MPRuntimeImageInsertConfigMixin> images =
            th2FileEditController.th2File.getImages();

        for (final MPRuntimeImageInsertConfigMixin image in images) {
          if (!image.isVisible) {
            continue;
          }

          final MPRuntimeXVIImageInsertConfigMixin? xviImage = image.asXVIImage;
          final MPRuntimeRasterImageInsertConfigMixin? rasterImage =
              image.asRasterImage;

          if (xviImage != null) {
            widgets.add(
              MPXVIImageWidget(
                key: ValueKey('xvi_image_${image.mpID}'),
                th2FileEditController: th2FileEditController,
                image: xviImage,
              ),
            );
          } else if (rasterImage != null) {
            widgets.add(
              MPRasterImageWidget(
                key: ValueKey('raster_image_${image.mpID}'),
                th2FileEditController: th2FileEditController,
                image: rasterImage,
              ),
            );
          }
        }

        final int? activeImageMPID =
            th2FileEditController.stateController.imageOperationImageMPID;

        if (activeImageMPID != null) {
          final MPRuntimeImageInsertConfigMixin activeImage =
              th2FileEditController.th2File.imageByMPID(activeImageMPID);
          final String? overlayLabel = th2FileEditController.stateController
              .getImageOperationOverlayLabelForImage(activeImageMPID);

          if (overlayLabel != null) {
            widgets.add(
              MPImageOperationOverlayWidget(
                key: ValueKey('image_operation_overlay_$activeImageMPID'),
                th2FileEditController: th2FileEditController,
                image: activeImage,
                label: overlayLabel,
                previewOffset: th2FileEditController.stateController
                    .getImageOperationPreviewOffsetForImage(activeImageMPID),
              ),
            );
          }
        }

        return RepaintBoundary(child: Stack(children: widgets));
      },
    );
  }
}
