library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/parameters/mp_move_command_original_parameters.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/stores/th2_file_edit_mode.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:mapiah/src/stores/types/mp_zoom_to_fit_type.dart';

part 'mixins/mp_th2_file_edit_state_get_selected_elements_mixin.dart';
part 'mixins/mp_th2_file_edit_state_move_canvas_mixin.dart';
part 'mp_th2_file_edit_state_moving.dart';
part 'mp_th2_file_edit_state_select_empty_selection.dart';
part 'mp_th2_file_edit_state_select_non_empty_selection.dart';
part 'types/mp_th2_file_edit_state_type.dart';

abstract class MPTH2FileEditState {
  final TH2FileEditStore th2FileEditStore;
  MPTH2FileEditStateType get type;

  MPTH2FileEditState({required this.th2FileEditStore});

  static MPTH2FileEditState getState({
    required MPTH2FileEditStateType type,
    required TH2FileEditStore thFileEditStore,
  }) {
    switch (type) {
      case MPTH2FileEditStateType.selectEmptySelection:
        return MPTH2FileEditStateSelectEmptySelection(
            th2FileEditStore: thFileEditStore);
      case MPTH2FileEditStateType.selectNonEmptySelection:
        return MPTH2FileEditStateSelectNonEmptySelection(
            th2FileEditStore: thFileEditStore);
      case MPTH2FileEditStateType.moving:
        return MPTH2FileEditStateMoving(th2FileEditStore: thFileEditStore);
    }
  }

  void setVisualMode() {}

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

  bool onButtonPressed(MPButtonType buttonType) {
    switch (buttonType) {
      case MPButtonType.changeScrap:
        th2FileEditStore.toggleToNextAvailableScrap();
        return true;
      case MPButtonType.redo:
        th2FileEditStore.redo();
        return true;
      case MPButtonType.select:
        th2FileEditStore.setState(th2FileEditStore.selectedElements.isEmpty
            ? MPTH2FileEditStateType.selectEmptySelection
            : MPTH2FileEditStateType.selectNonEmptySelection);
        return true;
      case MPButtonType.undo:
        th2FileEditStore.undo();
        return true;
      case MPButtonType.zoomAllFile:
        th2FileEditStore.zoomToFit(zoomFitToType: MPZoomToFitType.file);
        return true;
      case MPButtonType.zoomAllScrap:
        th2FileEditStore.zoomToFit(zoomFitToType: MPZoomToFitType.scrap);
        return true;
      case MPButtonType.zoomIn:
        th2FileEditStore.zoomIn();
        return true;
      case MPButtonType.zoomOneToOne:
        th2FileEditStore.zoomOneToOne();
        return true;
      case MPButtonType.zoomOptions:
        return true;
      case MPButtonType.zoomOut:
        th2FileEditStore.zoomOut();
        return true;
      case MPButtonType.zoomSelection:
        th2FileEditStore.zoomToFit(zoomFitToType: MPZoomToFitType.selection);
        return true;
      default:
        return false;
    }
  }
}
