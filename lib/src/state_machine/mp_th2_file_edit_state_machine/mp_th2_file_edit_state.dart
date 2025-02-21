library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/parameters/mp_move_command_original_params.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';

part 'mixins/mp_th2_file_edit_state_get_selected_elements_mixin.dart';
part 'mixins/mp_th2_file_edit_state_move_canvas_mixin.dart';
part 'mp_th2_file_edit_page_state_add_area.dart';
part 'mp_th2_file_edit_page_state_add_line.dart';
part 'mp_th2_file_edit_page_state_add_point.dart';
part 'mp_th2_file_edit_state_moving.dart';
part 'mp_th2_file_edit_state_select_empty_selection.dart';
part 'mp_th2_file_edit_state_select_non_empty_selection.dart';
part 'types/mp_th2_file_edit_state_type.dart';

abstract class MPTH2FileEditState {
  final TH2FileEditController th2FileEditController;
  MPTH2FileEditStateType get type;

  MPTH2FileEditState({required this.th2FileEditController});

  static MPTH2FileEditState getState({
    required MPTH2FileEditStateType type,
    required TH2FileEditController thFileEditController,
  }) {
    switch (type) {
      case MPTH2FileEditStateType.addArea:
        return MPTH2FileEditPageStateAddArea(
          th2FileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.addLine:
        return MPTH2FileEditPageStateAddLine(
          th2FileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.addPoint:
        return MPTH2FileEditPageStateAddPoint(
          th2FileEditController: thFileEditController,
        );

      case MPTH2FileEditStateType.moving:
        return MPTH2FileEditStateMoving(
          th2FileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.selectEmptySelection:
        return MPTH2FileEditStateSelectEmptySelection(
          th2FileEditController: thFileEditController,
        );
      case MPTH2FileEditStateType.selectNonEmptySelection:
        return MPTH2FileEditStateSelectNonEmptySelection(
          th2FileEditController: thFileEditController,
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

  void onStateLeave(MPTH2FileEditState nextState) {}

  bool onButtonPressed(MPButtonType buttonType) {
    switch (buttonType) {
      case MPButtonType.addArea:
        th2FileEditController.setState(MPTH2FileEditStateType.addArea);
        return true;
      case MPButtonType.addLine:
        th2FileEditController.setState(MPTH2FileEditStateType.addLine);
        return true;
      case MPButtonType.addPoint:
        th2FileEditController.setState(MPTH2FileEditStateType.addPoint);
        return true;
      case MPButtonType.changeScrap:
        th2FileEditController.toggleToNextAvailableScrap();
        return true;
      case MPButtonType.delete:
        th2FileEditController.deleteSelected();
        return true;
      case MPButtonType.redo:
        th2FileEditController.redo();
        return true;
      case MPButtonType.select:
        th2FileEditController.setState(
            th2FileEditController.selectedElements.isEmpty
                ? MPTH2FileEditStateType.selectEmptySelection
                : MPTH2FileEditStateType.selectNonEmptySelection);
        return true;
      case MPButtonType.undo:
        th2FileEditController.undo();
        return true;
      case MPButtonType.zoomAllFile:
        th2FileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.file);
        return true;
      case MPButtonType.zoomAllScrap:
        th2FileEditController.zoomToFit(zoomFitToType: MPZoomToFitType.scrap);
        return true;
      case MPButtonType.zoomIn:
        th2FileEditController.zoomIn();
        return true;
      case MPButtonType.zoomOneToOne:
        th2FileEditController.zoomOneToOne();
        return true;
      case MPButtonType.zoomOptions:
        return true;
      case MPButtonType.zoomOut:
        th2FileEditController.zoomOut();
        return true;
      case MPButtonType.zoomSelection:
        th2FileEditController.zoomToFit(
            zoomFitToType: MPZoomToFitType.selection);
        return true;
      default:
        return false;
    }
  }
}
