library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/commands/parameters/mp_move_command_original_parameters.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/selection/mp_selected_element.dart';
import 'package:mapiah/src/stores/th2_file_edit_mode.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

part 'mp_th2_file_edit_state_get_objects_inside_selection_window_mixin.dart';
part 'mp_th2_file_edit_state_moving.dart';
part 'mp_th2_file_edit_state_pan.dart';
part 'mp_th2_file_edit_state_select_empty_selection.dart';
part 'mp_th2_file_edit_state_select_non_empty_selection.dart';
part 'mp_th2_file_edit_state_type.dart';

abstract class MPTH2FileEditState {
  final TH2FileEditStore th2FileEditStore;
  MPTH2FileEditStateType get type;

  MPTH2FileEditState({required this.th2FileEditStore});

  static MPTH2FileEditState getState({
    required MPTH2FileEditStateType type,
    required TH2FileEditStore thFileEditStore,
  }) {
    switch (type) {
      case MPTH2FileEditStateType.pan:
        return MPTH2FileEditStatePan(th2FileEditStore: thFileEditStore);
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

  void onMiddleButtonScroll(PointerScrollEvent event) {}

  void onChangeActiveScrapToolPressed() {}

  void onPanToolPressed() {}

  void onSelectToolPressed() {}

  void onUndoPressed() {}

  void onRedoPressed() {}
}
