import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/mp_tile_widget.dart';

/// Presented in PLA options overlay window. By taping on it the user is
/// presented with a list of available PLA types at the
/// MPPLATypeOptionsOverlayWindowWidget overlay window.
class MPPLATypeWidget extends StatelessWidget {
  final String? selectedPLAType;
  final String? selectedPLATypeToUser;
  final THElementType elementType;
  final TH2FileEditController th2FileEditController;

  MPPLATypeWidget({
    super.key,
    required this.selectedPLAType,
    required this.selectedPLATypeToUser,
    required this.elementType,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    String title;

    switch (elementType) {
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

    final Key key = ValueKey('MPPLATypeWidget|$elementType|$selectedPLAType');

    return MPTileWidget(
      key: key,
      title: title,
      onTap: () => _onPLATypeTap(context),
    );
  }

  void _onPLATypeTap(BuildContext context) {
    Rect? boundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: context,
      ancestorGlobalKey: th2FileEditController.getTHFileWidgetGlobalKey(),
    );

    final Offset outerAnchorPosition = boundingBox == null
        ? th2FileEditController.screenBoundingBox.center
        : boundingBox.centerRight;

    th2FileEditController.overlayWindowController
        .performToggleShowPLATypeOverlayWindow(
          elementType: elementType,
          outerAnchorPosition: outerAnchorPosition,
          selectedPLAType: selectedPLAType,
        );
  }
}
