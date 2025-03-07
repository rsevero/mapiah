part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddArea extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddArea({required super.fileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    fileEditController.setStatusBarMessage(mpLocator.appLocalizations
        .th2FileEditPageAddAreaStatusBarMessage(
            addElementController.lastAddedAreaType.name));
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addArea;
}
