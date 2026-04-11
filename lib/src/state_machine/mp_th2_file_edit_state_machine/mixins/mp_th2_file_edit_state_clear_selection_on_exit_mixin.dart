// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateClearSelectionOnExitMixin on MPTH2FileEditState {
  static const Set<MPTH2FileEditStateType> selectionStatesTypes = {
    MPTH2FileEditStateType.addLineToArea,
    MPTH2FileEditStateType.editSingleLine,
    MPTH2FileEditStateType.elementRotate,
    MPTH2FileEditStateType.movingElements,
    MPTH2FileEditStateType.movingEndControlPoints,
    MPTH2FileEditStateType.movingSingleControlPoint,
    MPTH2FileEditStateType.selectEmptySelection,
    MPTH2FileEditStateType.selectionWindowZoom,
    MPTH2FileEditStateType.selectNonEmptySelection,
  };

  void onStateExitClearSelectionOnExit(MPTH2FileEditState nextState) {
    if (!selectionStatesTypes.contains(nextState.type)) {
      clearAllSelections();
    }
  }

  void clearAllSelections() {
    selectionController.clearSelectedElements();
    selectionController.clearSelectedLineSegments();
  }
}
