import 'dart:io' show File;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/mp_raster_image_painter.dart';

class MPRasterImageWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final THXTherionImageInsertConfig image;

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

    if (!widget.image.isXVI && widget.image.isVisible && !kIsWeb) {
      loadUIImage(widget.image.filename).then((img) {
        setState(() => _image = img);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.image.isXVI || !widget.image.isVisible || kIsWeb) {
      return SizedBox.shrink();
    }

    return Observer(
      builder: (_) {
        th2FileEditController.redrawTriggerNonSelectedElements;
        th2FileEditController.redrawTriggerImages;

        /// The Y coordinate is negated because in Therion's coordinate system,
        /// positive Y goes up, while in Flutter's canvas, positive Y goes down.
        final Offset offset = Offset(
          widget.image.xx.value,
          -widget.image.yy.value,
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

  Future<ui.Image> loadUIImage(String imagePath) async {
    final String resolvedPath = MPDirectoryAux.getResolvedPath(
      th2FileEditController.thFile.filename,
      imagePath,
    );

    final File file = File(resolvedPath);

    Uint8List bytes;
    if (await file.exists()) {
      bytes = await file.readAsBytes();
    } else {
      final ByteData assetData = await rootBundle.load(
        'assets/images/image_not_found.png',
      );

      bytes = assetData.buffer.asUint8List();
    }

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frame = await codec.getNextFrame();

    return frame.image;
  }
}
