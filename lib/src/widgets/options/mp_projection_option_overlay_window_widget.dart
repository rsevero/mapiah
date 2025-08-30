import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/options/mp_projection_option_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

/// Overlay wrapper preserving previous external usage API.
class MPProjectionOptionOverlayWindowWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPProjectionOptionOverlayWindowWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPProjectionOptionOverlayWindowWidget> createState() =>
      _MPProjectionOptionOverlayWindowWidgetState();
}

class _MPProjectionOptionOverlayWindowWidgetState
    extends State<MPProjectionOptionOverlayWindowWidget> {
  final GlobalKey<MPProjectionOptionWidgetState> _kernelKey = GlobalKey();
  AppLocalizations get _loc => mpLocator.appLocalizations;

  void _applyAndClose() {
    final state = _kernelKey.currentState;
    final opt = state?.buildCurrentOption();
    widget.th2FileEditController.userInteractionController.prepareSetOption(
      option: opt,
      optionType: widget.optionInfo.type,
    );
    widget.th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.optionChoices,
      false,
    );
  }

  void _cancel() {
    widget.th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.optionChoices,
      false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: _loc.thPointHeight,
      overlayWindowType: MPOverlayWindowType.secondary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: widget.innerAnchorType,
      th2FileEditController: widget.th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        MPOverlayWindowBlockWidget(
          overlayWindowBlockType: MPOverlayWindowBlockType.secondary,
          padding: mpOverlayWindowBlockEdgeInsets,
          children: [
            MPProjectionOptionWidget(
              key: _kernelKey,
              th2FileEditController: widget.th2FileEditController,
              optionInfo: widget.optionInfo,
              showActionButtons: true,
              onPressedOk: _applyAndClose,
              onPressedCancel: _cancel,
            ),
          ],
        ),
      ],
    );
  }
}
