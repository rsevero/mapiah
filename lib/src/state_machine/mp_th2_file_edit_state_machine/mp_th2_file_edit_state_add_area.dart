part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddArea extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddArea({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations.th2FileEditPageAddAreaStatusBarMessage(
        elementEditController.lastUsedAreaType.name,
      ),
    );
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    elementEditController.finalizeNewAreaCreation();
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    final Map<int, THElement> clickedLines = await selectionController
        .getSelectableElementsClickedWithDialog(
          screenCoordinates: event.localPosition,
          selectionType: THSelectionType.line,
          canBeMultiple: false,
          presentMultipleElementsClickedWidget: true,
        );

    if (clickedLines.isEmpty) {
      return Future.value();
    }

    final THArea area = elementEditController.getNewArea();
    final THLine line = clickedLines.values.first as THLine;

    if (!line.hasOption(THCommandOptionType.id)) {
      if (!area.hasOption(THCommandOptionType.id)) {
        elementEditController.addAutomaticTHIDOption(
          parent: area,
          prefix: mpAreaTHIDPrefix,
        );
      }

      final String areaTHID =
          (area.optionByType(THCommandOptionType.id) as THIDCommandOption).thID;
      final String lineTHIDPrefix = '$areaTHID-$mpLineTHIDPrefix';

      elementEditController.addAutomaticTHIDOption(
        parent: line,
        prefix: lineTHIDPrefix,
      );
    }

    final String lineTHID =
        (line.optionByType(THCommandOptionType.id) as THIDCommandOption).thID;
    final THAreaBorderTHID areaBorderTHID = THAreaBorderTHID(
      parentMPID: area.mpID,
      thID: lineTHID,
    );
    final MPCommand command = MPAddAreaBorderTHIDCommand(
      newAreaBorderTHID: areaBorderTHID,
    );

    th2FileEditController.execute(command);
    th2FileEditController.triggerNonSelectedElementsRedraw();

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
          elementEditController.finalizeNewAreaCreation();
          return;
        }
    }

    _onKeyDownEvent(event);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addArea;
}
