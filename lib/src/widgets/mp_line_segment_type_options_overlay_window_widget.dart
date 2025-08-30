import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPLineSegmentTypeOptionsOverlayWindowWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  MPLineSegmentTypeOptionsOverlayWindowWidget({
    super.key,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> choices = MPTextToUser.getOrderedChoices(
      MPTextToUser.getLineSegmentTypeChoices(),
    );
    final String title = mpLocator.appLocalizations.mpLineSegmentTypeTypesTitle;
    final MPSelectedLineSegmentType selectedType = th2FileEditController
        .selectionController
        .getSelectedLineSegmentsType();
    final String groupValue = selectedType.name;

    return MPOverlayWindowWidget(
      title: title,
      overlayWindowType: MPOverlayWindowType.secondary,
      outerAnchorPosition: outerAnchorPosition,
      innerAnchorType: innerAnchorType,
      th2FileEditController: th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        MPOverlayWindowBlockWidget(
          overlayWindowBlockType: MPOverlayWindowBlockType.choices,
          padding: mpOverlayWindowBlockEdgeInsets,
          children: [
            RadioGroup(
              groupValue: groupValue,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _onChanged(
                    context,
                    MPSelectedLineSegmentType.values.byName(newValue),
                  );
                }
              },
              child: Column(
                children: choices.entries.map((MapEntry<String, String> entry) {
                  return RadioListTile<String>(
                    key: ValueKey(
                      "MPLineSegmentTypeOptionsOverlayWindowWidget|RadioListTile|${entry.key}",
                    ),
                    title: Text(entry.value),
                    value: entry.key,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onChanged(BuildContext context, MPSelectedLineSegmentType newValue) {
    th2FileEditController.userInteractionController.prepareSetLineSegmentType(
      selectedLineSegmentType: newValue,
    );
    th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.lineSegmentTypes,
      false,
    );
  }
}
