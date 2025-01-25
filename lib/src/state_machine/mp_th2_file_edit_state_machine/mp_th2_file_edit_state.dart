library;

import 'package:flutter/material.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';

part 'mp_th2_file_edit_state_moving.dart';
part 'mp_th2_file_edit_state_pan.dart';
part 'mp_th2_file_edit_state_select_empty_selection.dart';
part 'mp_th2_file_edit_state_select_non_empty_selection.dart';

enum MPTH2FileEditStateType {
  pan,
  selectEmptySelection,
  selectNonEmptySelection,
  moving,
}

abstract class MPTH2FileEditState {
  final TH2FileEditStore thFileEditStore;
  MPTH2FileEditStateType get type;

  MPTH2FileEditState({required this.thFileEditStore});

  static MPTH2FileEditState getState({
    required MPTH2FileEditStateType type,
    required TH2FileEditStore thFileEditStore,
  }) {
    switch (type) {
      case MPTH2FileEditStateType.pan:
        return MPTH2FileEditStatePan(thFileEditStore: thFileEditStore);
      case MPTH2FileEditStateType.selectEmptySelection:
        return MPTH2FileEditStateSelectEmptySelection(
            thFileEditStore: thFileEditStore);
      case MPTH2FileEditStateType.selectNonEmptySelection:
        return MPTH2FileEditStateSelectNonEmptySelection(
            thFileEditStore: thFileEditStore);
      case MPTH2FileEditStateType.moving:
        return MPTH2FileEditStateMoving(thFileEditStore: thFileEditStore);
    }
  }

  void setCursor() {}

  void setStatusBarMessage() {}

  void onTapUp(TapUpDetails details) {}

  void onPanStart(DragStartDetails details) {}

  void onPanUpdate(DragUpdateDetails details) {}

  void onPanEnd(DragEndDetails details) {}

  void onPanToolPressed() {}

  void onSelectToolPressed() {}
}
