part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditPageStateAddLine extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditPageStateAddLine({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(mpLocator.appLocalizations
        .th2FileEditPageAddLineStatusBarMessage(
            th2FileEditController.lastAddedLineType.name));
  }

  @override
  void onPrimaryButtonClick(PointerUpEvent event) {
    th2FileEditController.addNewLineLineSegment(event.localPosition);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addLine;
}
