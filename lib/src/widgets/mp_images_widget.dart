import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/mp_raster_image_widget.dart';
import 'package:mapiah/src/widgets/mp_xvi_image_widget.dart';

class MPImagesWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  const MPImagesWidget({super.key, required this.th2FileEditController});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNonSelectedElements;
        th2FileEditController.redrawTriggerImages;

        final List<Widget> widgets = [];
        final Iterable<THXTherionImageInsertConfig> images =
            th2FileEditController.thFile.getXTherionImageInsertConfigs();

        for (final THXTherionImageInsertConfig image in images) {
          if (!image.isVisible) continue;

          widgets.add(
            image.isXVI
                ? MPXVIImageWidget(
                    th2FileEditController: th2FileEditController,
                    image: image,
                  )
                : MPRasterImageWidget(
                    th2FileEditController: th2FileEditController,
                    image: image,
                  ),
          );
        }

        return RepaintBoundary(child: Stack(children: widgets));
      },
    );
  }
}
