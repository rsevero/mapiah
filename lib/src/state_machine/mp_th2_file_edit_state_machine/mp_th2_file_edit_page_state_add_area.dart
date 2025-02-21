part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditPageStateAddArea extends MPTH2FileEditState {
  MPTH2FileEditPageStateAddArea({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(mpLocator.appLocalizations
        .th2FileEditPageAddAreaStatusBarMessage(
            th2FileEditController.lastAddedAreaType.name));
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addArea;
}
