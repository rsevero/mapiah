library;

import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/parameters/mp_move_command_original_params.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/controllers/th2_file_edit_add_element_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';

part 'mixins/mp_th2_file_edit_state_clear_selection_on_exit_mixin.dart';
part 'mixins/mp_th2_file_edit_state_get_selected_elements_mixin.dart';
part 'mixins/mp_th2_file_edit_state_move_canvas_mixin.dart';
part 'mp_th2_file_edit_state_add_area.dart';
part 'mp_th2_file_edit_state_add_line.dart';
part 'mp_th2_file_edit_state_add_point.dart';
part 'mp_th2_file_edit_state_edit_single_line.dart';
part 'mp_th2_file_edit_state_moving_elements.dart';
part 'mp_th2_file_edit_state_moving_end_control_points.dart';
part 'mp_th2_file_edit_state_moving_single_control_point.dart';
part 'mp_th2_file_edit_state_select_empty_selection.dart';
part 'mp_th2_file_edit_state_select_non_empty_selection.dart';
part 'types/mp_th2_file_edit_state_type.dart';

abstract class MPTH2FileEditState {
  final TH2FileEditController fileEditController;
  final TH2FileEditAddElementController addElementController;
  final TH2FileEditSelectionController selectionController;
  MPTH2FileEditStateType get type;

  MPTH2FileEditState({required this.fileEditController})
      : addElementController = fileEditController.addElementController,
        selectionController = fileEditController.selectionController;

  static MPTH2FileEditState getState({
    required MPTH2FileEditStateType type,
    required TH2FileEditController thFileEditController,
  }) {
    switch (type) {
      case MPTH2FileEditStateType.addArea:
        return MPTH2FileEditStateAddArea(
          fileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.addLine:
        return MPTH2FileEditStateAddLine(
          fileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.addPoint:
        return MPTH2FileEditStateAddPoint(
          fileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.editSingleLine:
        return MPTH2FileEditStateEditSingleLine(
          fileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.movingElements:
        return MPTH2FileEditStateMovingElements(
          fileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.movingEndControlPoints:
        return MPTH2FileEditStateMovingEndControlPoints(
          fileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.movingSingleControlPoint:
        return MPTH2FileEditStateMovingSingleControlPoint(
          fileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.selectEmptySelection:
        return MPTH2FileEditStateSelectEmptySelection(
          fileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.selectNonEmptySelection:
        return MPTH2FileEditStateSelectNonEmptySelection(
          fileEditController: thFileEditController,
        );
    }
  }

  void setCursor() {}

  void setStatusBarMessage() {}

  void onPrimaryButtonDragStart(PointerDownEvent event) {}

  void onSecondaryButtonDragStart(PointerDownEvent event) {}

  void onTertiaryButtonDragStart(PointerDownEvent event) {}

  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {}

  void onSecondaryButtonDragUpdate(PointerMoveEvent event) {}

  void onTertiaryButtonDragUpdate(PointerMoveEvent event) {}

  void onPrimaryButtonDragEnd(PointerUpEvent event) {}

  void onSecondaryButtonDragEnd(PointerUpEvent event) {}

  void onTertiaryButtonDragEnd(PointerUpEvent event) {}

  void onPrimaryButtonClick(PointerUpEvent event) {}

  void onSecondaryButtonClick(PointerUpEvent event) {}

  void onTertiaryButtonClick(PointerUpEvent event) {}

  void onTertiaryButtonScroll(PointerScrollEvent event) {}

  void onKeyDownEvent(KeyDownEvent event) {}

  void onKeyRepeatEvent(KeyRepeatEvent event) {}

  void onKeyUpEvent(KeyUpEvent event) {}

  void onStateEnter(MPTH2FileEditState previousState) {}

  void onStateExit(MPTH2FileEditState nextState) {}

  bool onButtonPressed(MPButtonType buttonType) {
    switch (buttonType) {
      case MPButtonType.addArea:
        fileEditController.setState(MPTH2FileEditStateType.addArea);
        return true;
      case MPButtonType.addLine:
        fileEditController.setState(MPTH2FileEditStateType.addLine);
        return true;
      case MPButtonType.addPoint:
        fileEditController.setState(MPTH2FileEditStateType.addPoint);
        return true;
      case MPButtonType.changeScrap:
        fileEditController.toggleToNextAvailableScrap();
        return true;
      case MPButtonType.delete:
        selectionController.deleteSelected();
        return true;
      case MPButtonType.redo:
        fileEditController.redo();
        return true;
      case MPButtonType.select:
        selectionController.setSelectionState();
        return true;
      case MPButtonType.undo:
        fileEditController.undo();
        return true;
      case MPButtonType.zoomAllFile:
        fileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.file);
        return true;
      case MPButtonType.zoomAllScrap:
        fileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.scrap);
        return true;
      case MPButtonType.zoomIn:
        fileEditController.zoomIn();
        return true;
      case MPButtonType.zoomOneToOne:
        fileEditController.zoomOneToOne();
        return true;
      case MPButtonType.zoomOptions:
        return true;
      case MPButtonType.zoomOut:
        fileEditController.zoomOut();
        return true;
      case MPButtonType.zoomSelection:
        fileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.selection);
        return true;
      default:
        return false;
    }
  }
}
