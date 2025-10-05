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
    final MPCommand? addLineToAreaCommand = await getAddLineToAreaCommand(
      event: event,
      th2FileEditController: th2FileEditController,
      area: area,
    );

    if (addLineToAreaCommand == null) {
      elementEditController.applyRemoveArea(area.mpID);

      return Future.value();
    }

    final MPCommand addAreaCommand = MPAddAreaCommand.fromExisting(
      existingArea: area,
      th2FileEditController: th2FileEditController,
    );
    final List<MPCommand> commands = [addAreaCommand, addLineToAreaCommand];
    final MPCommand addAreaWithLineCommand = MPMultipleElementsCommand.forCWJM(
      commandsList: commands,
      completionType: MPMultipleElementsCommandCompletionType.elementsEdited,
      descriptionType: MPCommandDescriptionType.addArea,
    );

    th2FileEditController.execute(addAreaWithLineCommand);
    th2FileEditController.triggerAllElementsRedraw();

    return Future.value();
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
