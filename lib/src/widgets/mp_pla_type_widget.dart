import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

class MPPLATypeWidget extends StatelessWidget {
  final String? selectedPLAType;
  final THElementType type;
  final TH2FileEditController th2FileEditController;

  MPPLATypeWidget({
    super.key,
    required this.selectedPLAType,
    required this.type,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    String title;

    switch (type) {
      case THElementType.area:
        title = selectedPLAType == null
            ? mpLocator.appLocalizations.mpPLATypeAreaTitle
            : selectedPLAType!;
      case THElementType.line:
        title = selectedPLAType == null
            ? mpLocator.appLocalizations.mpPLATypeLineTitle
            : selectedPLAType!;
      case THElementType.point:
        title = selectedPLAType == null
            ? mpLocator.appLocalizations.mpPLATypePointTitle
            : selectedPLAType!;
      default:
        return SizedBox.shrink();
    }

    return ListTile(
      title: Text(title),
      onTap: () => _onPLATypeTap(context),
    );
  }

  void _onPLATypeTap(BuildContext context) {
    Rect? boundingBox = MPInteractionAux.getWidgetRectFromContext(
      context: context,
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
