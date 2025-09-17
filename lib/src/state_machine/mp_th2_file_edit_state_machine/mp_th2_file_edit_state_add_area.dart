part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddArea extends MPTH2FileEditState
    with
        MPTH2FileEditPageStateAddLineToAreaMixin,
        MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddArea({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations.th2FileEditPageAddAreaStatusBarMessage(
        elementEditController.lastUsedAreaType,
      ),
    );
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    elementEditController.finalizeNewAreaCreation();
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    final THArea area = elementEditController.getNewArea();

    return addLineToArea(
      event: event,
      th2FileEditController: th2FileEditController,
      area: area,
    );
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    final bool isAltPressed = MPInteractionAux.isAltPressed();
    final bool isCtrlPressed = MPInteractionAux.isCtrlPressed();
    final bool isShiftPressed = MPInteractionAux.isShiftPressed();

    switch (event.logicalKey) {
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        if (!isCtrlPressed && !isAltPressed && !isShiftPressed) {
          selectionController.setSelectedElements([
            elementEditController.getNewArea(),
          ], setState: true);

          return;
        }
    }

    _onKeyDownEvent(event);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addArea;
}
