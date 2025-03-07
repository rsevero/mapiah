part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddLine extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddLine({required super.fileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    fileEditController.setStatusBarMessage(mpLocator.appLocalizations
        .th2FileEditPageAddLineStatusBarMessage(
            addElementController.lastAddedLineType.name));
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    addElementController.finalizeNewLineCreation();
  }

  @override
  void onPrimaryButtonDragStart(PointerDownEvent event) {
    addElementController.addNewLineLineSegment(event.localPosition);
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    addElementController.updateBezierLineSegment(event.localPosition);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addLine;
}
