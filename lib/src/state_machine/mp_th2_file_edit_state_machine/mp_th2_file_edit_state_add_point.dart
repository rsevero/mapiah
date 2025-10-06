part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddPoint extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddPoint({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations.th2FileEditPageAddPointStatusBarMessage(
        elementEditController.lastUsedPointType,
      ),
    );
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) {
    final MPCommand command = MPCommandFactory.addPoint(
      screenPosition: event.localPosition,
      pointTypeString: elementEditController.lastUsedPointType,
      th2FileEditController: th2FileEditController,
    );

    th2FileEditController.execute(command);
    th2FileEditController.triggerNonSelectedElementsRedraw();

    return Future.value();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addPoint;
}
