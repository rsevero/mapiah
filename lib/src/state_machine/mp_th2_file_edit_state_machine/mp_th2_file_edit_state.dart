library;

import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
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

  List<THElement> _getObjectsInsideSelectionWindow(
    Offset screenCoordinatesEndSelectionWindow,
  ) {
    final Offset startSelectionWindow = th2FileEditStore.panStartCoordinates;
    final Offset endSelectionWindow = th2FileEditStore
        .offsetScreenToCanvas(screenCoordinatesEndSelectionWindow);
    final Rect selectionWindow = Rect.fromLTRB(
      startSelectionWindow.dx,
      startSelectionWindow.dy,
      endSelectionWindow.dx,
      endSelectionWindow.dy,
    );
    final List<THElement> elementsInsideSelectionWindow =
        th2FileEditStore.selectableElementsInsideWindow(selectionWindow);

    return elementsInsideSelectionWindow;
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
