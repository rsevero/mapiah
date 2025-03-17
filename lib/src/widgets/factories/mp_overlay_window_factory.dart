import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/mp_available_scraps_widget.dart';
import 'package:mapiah/src/widgets/mp_options_edit_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPOverlayWindowFactory {
  static Widget create({
    required TH2FileEditController th2FileEditController,
    required Offset position,
    required MPOverlayWindowType type,
  }) {
    final TH2FileEditOverlayWindowController overlayWindowController =
        th2FileEditController.overlayWindowController;
    final int thFileMapiahID = th2FileEditController.thFileMapiahID;

    switch (type) {
      case MPOverlayWindowType.availableScraps:
        final GlobalKey changeScrapButtonKey = overlayWindowController
            .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType.changeScrapButton]!;
        final Rect? rect = MPInteractionAux.getWidgetRect(changeScrapButtonKey);

        if (rect != null) {
          position = Offset(rect.left - mpButtonSpace, rect.center.dy);
        }

        return MPAvailableScrapsWidget(
          key: ValueKey("MPAvailableScrapsWidget|$thFileMapiahID"),
          th2FileEditController: th2FileEditController,
          position: position,
        );
      case MPOverlayWindowType.commandOptions:
        return MPOptionsEditWidget(
          key: ValueKey("MPOptionsEditWidget|$thFileMapiahID"),
          th2FileEditController: th2FileEditController,
          position: position,
          positionType: MPWidgetPositionType.center,
        );
    }
  }
}
