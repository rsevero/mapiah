import 'package:dart_numerics/dart_numerics.dart' as numerics;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapiah/src/th_controllers/th_file_controller.dart';
import 'package:mapiah/src/th_definitions/th_definitions.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_scrap.dart';
import 'package:mapiah/src/th_widgets/th_scrap_widget.dart';

class THFileWidget extends StatelessWidget {
  final THFile file;
  final List<Widget> children = [];
  final THFileController thFileController = Get.put(THFileController());
  late final Rect _dataBoundingBox;

  THFileWidget(this.file) : super(key: ObjectKey(file)) {
    _dataBoundingBox = file.boundingBox();
    for (final child in file.children) {
      if (child is THScrap) {
        children.add(THScrapWidget(child));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasWidth = constraints.maxWidth;
        final canvasHeight = constraints.maxHeight;
        thFileController.updateCanvasSize(Size(canvasWidth, canvasHeight));

        if (thFileController.canvasScaleOffsetUndefined) {
          final double dataWidth =
              (numerics.almostEqual(_dataBoundingBox.width, 0)
                  ? 1.0
                  : _dataBoundingBox.width);
          final double dataHeight =
              (numerics.almostEqual(_dataBoundingBox.height, 0)
                  ? 1.0
                  : _dataBoundingBox.height);
          final double widthScale =
              (canvasWidth * (1.0 - thCanvasMargin)) / dataWidth;
          final double heightScale =
              (canvasHeight * (1.0 - thCanvasMargin)) / dataHeight;
          final scale = widthScale < heightScale ? widthScale : heightScale;
          thFileController.updateCanvasScale(scale);

          final double xOffset = -(_dataBoundingBox.left -
              ((canvasWidth - (_dataBoundingBox.width * scale)) / 2));
          final double yOffset = -(_dataBoundingBox.top -
              ((canvasHeight - (_dataBoundingBox.height * scale)) / 2));
          thFileController.updateCanvasOffset(Offset(xOffset, yOffset));

          thFileController.canvasScaleOffsetUndefined = false;
        }

        return Stack(children: children);
      },
    );
  }
}
