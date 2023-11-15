import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_elements/th_scrap.dart';
import 'package:mapiah/src/th_widgets/th_scrap_widget.dart';

class THFileWidget extends StatelessWidget {
  final THFile file;
  final List<Widget> children = [];
  final THFileController thFileController = Get.put(THFileController());

  THFileWidget(this.file) : super(key: ObjectKey(file)) {
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
        thFileController.updateCanvasSize(
            Size(constraints.maxWidth, constraints.maxHeight));
        return Stack(children: children);
      },
    );
  }
}

class THFileController extends GetxController {
  // Reactive canvas size
  var canvasSize = Size.zero.obs;

  // Method to update the canvas size
  void updateCanvasSize(Size newSize) {
    canvasSize.value = newSize;
  }
}
