part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateClearSelectionOnExitMixin on MPTH2FileEditState {
  static const _selectionStatesTypes = [
    MPTH2FileEditStateType.editSingleLine,
    MPTH2FileEditStateType.movingElements,
    MPTH2FileEditStateType.movingEndControlPoints,
    MPTH2FileEditStateType.selectEmptySelection,
    MPTH2FileEditStateType.selectNonEmptySelection,
  ];

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    if (_selectionStatesTypes.contains(nextState.type)) {
      return;
    }

    th2FileEditController.clearSelectedElements();
    th2FileEditController.clearSelectedLineSegments();
  }
}
