part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditPageStateAddPoint extends MPTH2FileEditState {
  MPTH2FileEditPageStateAddPoint({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(mpLocator.appLocalizations
        .th2FileEditPageAddPointStatusBarMessage(
            th2FileEditController.lastAddedPointType));
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addPoint;
}
