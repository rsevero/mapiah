// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/painters/mp_element_transform_handles_painter.dart';
import 'package:mapiah/src/painters/mp_selection_handles_painter.dart';
import 'package:mapiah/src/painters/types/mp_selection_handle_type.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';

class MPSelectionHandlesWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;
  final TH2FileEditSelectionController selectionController;
  final int thFileMPID;

  MPSelectionHandlesWidget({
    required this.th2FileEditController,
    required super.key,
  }) : selectionController = th2FileEditController.selectionController,
       thFileMPID = th2FileEditController.th2FileMPID;

  @override
  Widget build(Object context) {
    return RepaintBoundary(
      child: Observer(
        builder: (_) {
          th2FileEditController.redrawTriggerAllElements;
          th2FileEditController.redrawTriggerSelectedElements;
          th2FileEditController.redrawTriggerSelectedElementsListChanged;

          final bool shouldShowElementTransformHandles = th2FileEditController
              .moveScaleRotateElementController
              .shouldShowElementTransformHandles;

          if (shouldShowElementTransformHandles) {
            final Offset hoverScreenPosition =
                th2FileEditController.mousePosition;
            final MPTH2FileEditStateType stateType =
                th2FileEditController.stateController.state.type;
            final bool isRotateMode =
                stateType == MPTH2FileEditStateType.elementRotate;
            final Rect canvasBoundingBox =
                selectionController.selectedElementsBoundingBox;

            return CustomPaint(
              painter: MPElementTransformHandlesPainter(
                th2FileEditController: th2FileEditController,
                canvasBoundingBox: canvasBoundingBox,
                hoverScreenPosition: hoverScreenPosition,
                isRotateMode: isRotateMode,
              ),
              size: th2FileEditController.screenSize,
            );
          }

          final Map<MPSelectionHandleType, Offset> handleCenters =
              selectionController.getSelectionHandleCenters();
          final Paint handlePaint = th2FileEditController.selectionHandlePaint;

          final Rect boundingBox =
              selectionController.selectedElementsBoundingBox;
          double handleSize = th2FileEditController.selectionHandleSizeOnCanvas;
          final double handleSizeThreshold =
              handleSize * mpSelectionHandleThresholdMultiplier;
          if ((boundingBox.width > handleSizeThreshold) &&
              (boundingBox.height > handleSizeThreshold)) {
            handleSize = handleSize * mpSelectionHandleSizeAmplifier;
          }

          return CustomPaint(
            painter: MPSelectionHandlesPainter(
              th2FileEditController: th2FileEditController,
              handleCenters: handleCenters,
              handleSize: handleSize,
              handlePaint: handlePaint,
            ),
          );
        },
      ),
    );
  }
}
