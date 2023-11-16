import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapiah/src/th_controllers/th_file_controller.dart';
import 'package:mapiah/src/th_elements/th_area.dart';
import 'package:mapiah/src/th_elements/th_line.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_elements/th_scrap.dart';
import 'package:mapiah/src/th_widgets/th_point_widget.dart';

class THScrapWidget extends StatelessWidget {
  final THScrap scrap;
  final List<Widget> children = [];
  final THFileController thFileController = Get.put(THFileController());

  THScrapWidget(this.scrap) : super(key: ObjectKey(scrap)) {
    for (final child in scrap.children) {
      if (child is THPoint) {
        children.add(THPointWidget(child));
        // } else if (child is THLine) {
        //   children.add(THLineWidget(child));
        // } else if (child is THArea) {
        //   children.add(THAreaWidget(child));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: children);
  }
}
