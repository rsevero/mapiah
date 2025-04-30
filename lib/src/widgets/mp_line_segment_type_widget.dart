import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_tile_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';

/// Used in MPLineSegmentTypeOptionsOverlayWindowWidget to present the current
/// line segment type.
class MPLineSegmentTypeWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  MPLineSegmentTypeWidget({
    super.key,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    final String title;
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    final MPSelectedLineSegmentType lineSegmentsType =
        th2FileEditController.selectionController.getSelectedLineSegmentsType();

    switch (lineSegmentsType) {
      case MPSelectedLineSegmentType.bezierCurveLineSegment:
        title = appLocalizations.thElementBezierCurveLineSegment;
      case MPSelectedLineSegmentType.mixed:
        title = appLocalizations.mpOptionsEditLineSegmentTypes;
      case MPSelectedLineSegmentType.straightLineSegment:
        title = appLocalizations.thElementStraightLineSegment;
      default:
        throw Exception(
          'Unknown line segment type: $lineSegmentsType',
        );
    }

    return MPOverlayWindowBlockWidget(
      children: [
        MPTileWidget(
          title: title,
          onTap: () => _onLineSegmentTypeTap(context),
        ),
      ],
      overlayWindowBlockType: MPOverlayWindowBlockType.main,
    );
  }

  void _onLineSegmentTypeTap(BuildContext context) {
    Rect? boundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: context,
      ancestorGlobalKey: th2FileEditController.thFileWidgetKey,
    );

    final Offset outerAnchorPosition = boundingBox == null
        ? th2FileEditController.screenBoundingBox.center
        : boundingBox.centerRight;

    th2FileEditController.overlayWindowController
        .perfomToggleLineSegmentTypeOptionsOverlayWindow(
      outerAnchorPosition: outerAnchorPosition,
    );
  }
}
