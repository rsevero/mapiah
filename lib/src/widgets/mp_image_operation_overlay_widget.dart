// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/painters/mp_image_operation_overlay_painter.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';

/// Paints the transient UI that explains which image is currently being edited.
///
/// This widget does not render the image itself. Instead, it draws the scale
/// handles used by the combined move/scale mode for the active image.
///
/// Its role in the image-edit flow is purely communicative:
/// - identify the image currently bound to the image-operation state
/// - show which operation mode is active
/// - follow the live preview offset while the user drags the image
///
/// `IgnorePointer` keeps this overlay from stealing mouse interaction from the
/// canvas, so dragging still reaches the state machine normally.
class MPImageOperationOverlayWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final MPRuntimeImageInsertConfigMixin image;

  const MPImageOperationOverlayWidget({
    super.key,
    required this.th2FileEditController,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final Offset hoverScreenPosition = th2FileEditController.mousePosition;

        return IgnorePointer(
          child: CustomPaint(
            painter: MPImageOperationOverlayPainter(
              th2FileEditController: th2FileEditController,
              image: image,
              hoverScreenPosition: hoverScreenPosition,
              isRotateMode:
                  th2FileEditController.stateController.state.type ==
                  MPTH2FileEditStateType.imageRotate,
            ),
            size: th2FileEditController.screenSize,
          ),
        );
      },
    );
  }
}
