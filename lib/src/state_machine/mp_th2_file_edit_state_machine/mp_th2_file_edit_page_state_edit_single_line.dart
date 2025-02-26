part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditPageStateEditSingleLine extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditPageStateEditSingleLine({required super.th2FileEditController});

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.editSingleLine;
}
