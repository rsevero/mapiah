library;

import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_edit_element_aux.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_snap_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mixins/mp_th2_file_edit_page_simplify_line_mixin.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';

part 'mixins/mp_th2_file_edit_page_single_element_selected_mixin.dart';
part 'mixins/mp_th2_file_edit_page_state_add_line_to_area_mixin.dart';
part 'mixins/mp_th2_file_edit_state_clear_selection_on_exit_mixin.dart';
part 'mixins/mp_th2_file_edit_state_get_selected_elements_mixin.dart';
part 'mixins/mp_th2_file_edit_state_line_segment_options_edit_mixin.dart';
part 'mixins/mp_th2_file_edit_state_move_canvas_mixin.dart';
part 'mixins/mp_th2_file_edit_state_options_edit_mixin.dart';
part 'mp_th2_file_edit_state_add_area.dart';
part 'mp_th2_file_edit_state_add_line_to_area.dart';
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
  final TH2FileEditController th2FileEditController;
  final TH2FileEditElementEditController elementEditController;
  final TH2FileEditSelectionController selectionController;
  final THFile thFile;
  MPTH2FileEditStateType get type;

  MPTH2FileEditState({required this.th2FileEditController})
    : elementEditController = th2FileEditController.elementEditController,
      selectionController = th2FileEditController.selectionController,
      thFile = th2FileEditController.thFile;

  static MPTH2FileEditState getState({
    required MPTH2FileEditStateType type,
    required TH2FileEditController th2FileEditController,
  }) {
    switch (type) {
      case MPTH2FileEditStateType.addArea:
        return MPTH2FileEditStateAddArea(
          th2FileEditController: th2FileEditController,
        );
      case MPTH2FileEditStateType.addLine:
        return MPTH2FileEditStateAddLine(
          th2FileEditController: th2FileEditController,
        );
      case MPTH2FileEditStateType.addLineToArea:
        return MPTH2FileEditStateAddLineToArea(
          th2FileEditController: th2FileEditController,
        );
      case MPTH2FileEditStateType.addPoint:
        return MPTH2FileEditStateAddPoint(
          th2FileEditController: th2FileEditController,
        );
      case MPTH2FileEditStateType.editSingleLine:
        return MPTH2FileEditStateEditSingleLine(
          th2FileEditController: th2FileEditController,
        );
      case MPTH2FileEditStateType.movingElements:
        return MPTH2FileEditStateMovingElements(
          th2FileEditController: th2FileEditController,
        );
      case MPTH2FileEditStateType.movingEndControlPoints:
        return MPTH2FileEditStateMovingEndControlPoints(
          th2FileEditController: th2FileEditController,
        );
      case MPTH2FileEditStateType.movingSingleControlPoint:
        return MPTH2FileEditStateMovingSingleControlPoint(
          th2FileEditController: th2FileEditController,
        );
      case MPTH2FileEditStateType.selectEmptySelection:
        return MPTH2FileEditStateSelectEmptySelection(
          th2FileEditController: th2FileEditController,
        );
      case MPTH2FileEditStateType.selectNonEmptySelection:
        return MPTH2FileEditStateSelectNonEmptySelection(
          th2FileEditController: th2FileEditController,
        );
    }
  }

  void setCursor() {}

  void setStatusBarMessage() {}

  void onPrimaryButtonPointerDown(PointerDownEvent event) {}

  void onSecondaryButtonPointerDown(PointerDownEvent event) {}

  void onTertiaryButtonPointerDown(PointerDownEvent event) {}

  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {}

  void onSecondaryButtonDragUpdate(PointerMoveEvent event) {}

  void onTertiaryButtonDragUpdate(PointerMoveEvent event) {}

  void onPrimaryButtonDragEnd(PointerUpEvent event) {}

  void onSecondaryButtonDragEnd(PointerUpEvent event) {}

  void onTertiaryButtonDragEnd(PointerUpEvent event) {}

  Future<void> onPrimaryButtonClick(PointerUpEvent event) {
    return Future.value();
  }

  void onSecondaryButtonClick(PointerUpEvent event) {}

  void onTertiaryButtonClick(PointerUpEvent event) {}

  void onTertiaryButtonScroll(PointerScrollEvent event) {}

  void onDeselectAll() {}

  void onKeyDownEvent(KeyDownEvent event) {}

  void onKeyRepeatEvent(KeyRepeatEvent event) {}

  void onKeyUpEvent(KeyUpEvent event) {}

  void onSelectAll() {}

  void onStateEnter(MPTH2FileEditState previousState) {}

  void onStateExit(MPTH2FileEditState nextState) {}

  bool onButtonPressed(MPButtonType buttonType) {
    switch (buttonType) {
      case MPButtonType.addArea:
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.addArea,
        );
        return true;
      case MPButtonType.addImage:
        th2FileEditController.elementEditController.addImage();
        return true;
      case MPButtonType.addLine:
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.addLine,
        );
        return true;
      case MPButtonType.addLineToArea:
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.addLineToArea,
        );
        return true;
      case MPButtonType.addPoint:
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.addPoint,
        );
        return true;
      case MPButtonType.addScrap:
        th2FileEditController.elementEditController.addScrap();
        return true;
      case MPButtonType.changeScrap:
        th2FileEditController.toggleToNextAvailableScrap();
        return true;
      case MPButtonType.nodeEdit:
        th2FileEditController.stateController.setState(
          MPTH2FileEditStateType.editSingleLine,
        );
        return true;
      case MPButtonType.redo:
        th2FileEditController.redo();
        return true;
      case MPButtonType.remove:
        selectionController.removeSelected();
        return true;
      case MPButtonType.select:
        selectionController.setSelectionState();
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
          zoomFitToType: MPZoomToFitType.selection,
        );
        return true;
      default:
        return false;
    }
  }
}
