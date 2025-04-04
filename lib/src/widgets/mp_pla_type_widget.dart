import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/mp_tile_widget.dart';

class MPPLATypeWidget extends StatelessWidget {
  final String? selectedPLAType;
  final String? selectedPLATypeToUser;
  final THElementType type;
  final TH2FileEditController th2FileEditController;

  MPPLATypeWidget({
    super.key,
    required this.selectedPLAType,
    required this.selectedPLATypeToUser,
    required this.type,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    String title;

    switch (type) {
      case THElementType.area:
        title = selectedPLATypeToUser == null
            ? mpLocator.appLocalizations.mpPLATypeAreaTitle
            : selectedPLATypeToUser!;
      case THElementType.line:
        title = selectedPLATypeToUser == null
            ? mpLocator.appLocalizations.mpPLATypeLineTitle
            : selectedPLATypeToUser!;
      case THElementType.point:
        title = selectedPLATypeToUser == null
            ? mpLocator.appLocalizations.mpPLATypePointTitle
            : selectedPLATypeToUser!;
      default:
        return SizedBox.shrink();
    }

    return MPTileWidget(
      title: title,
      onTap: () => _onPLATypeTap(context),
    );
  }

  void _onPLATypeTap(BuildContext context) {
    Rect? boundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: context,
      ancestorGlobalKey: th2FileEditController.thFileWidgetKey,
    );

    final Offset position = boundingBox == null
        ? th2FileEditController.screenBoundingBox.center
        : boundingBox.centerRight;

    th2FileEditController.overlayWindowController
        .performToggleShowPLATypeOverlayWindow(
      elementType: type,
      position: position,
      selectedType: selectedPLAType,
    );
  }
}
