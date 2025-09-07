part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateOptionEdit extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin {
  static const Set<MPTH2FileEditStateType> singleLineEditModes = {
    MPTH2FileEditStateType.editSingleLine,
    MPTH2FileEditStateType.movingSingleControlPoint,
    MPTH2FileEditStateType.movingEndControlPoints,
  };

  MPTH2FileEditStateOptionEdit({required super.th2FileEditController});

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.optionsEdit;
}
