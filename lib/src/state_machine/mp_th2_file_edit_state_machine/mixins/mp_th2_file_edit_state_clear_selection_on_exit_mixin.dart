part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateClearSelectionOnExitMixin on MPTH2FileEditState {
  static const Set<MPTH2FileEditStateType> selectionStatesTypes = {
    MPTH2FileEditStateType.addLineToArea,
    MPTH2FileEditStateType.editSingleLine,
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
