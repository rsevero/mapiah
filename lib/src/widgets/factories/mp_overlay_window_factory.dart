import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/mp_options_edit_content_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOverlayWindowFactory {
  static Widget create({
    required TH2FileEditController th2FileEditController,
    required Offset position,
    required MPOverlayWindowType type,
  }) {
    final TH2FileEditOverlayWindowController overlayWindowController =
        th2FileEditController.overlayWindowController;
    final GlobalKey globalKey =
        overlayWindowController.overlayWindowKeyByType[type]!;

    switch (type) {
      case MPOverlayWindowType.availableScraps:
        return MPOptionsEditContentWidget(
          th2FileEditController: th2FileEditController,
          position: position,
          positionType: MPWidgetPositionType.rightCenter,
          globalKey: globalKey,
        );
      case MPOverlayWindowType.commandOptions:
        return MPOptionsEditContentWidget(
          th2FileEditController: th2FileEditController,
          position: position,
          positionType: MPWidgetPositionType.center,
          globalKey: globalKey,
        );
    }
  }
}
