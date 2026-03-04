part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddArea extends MPTH2FileEditState
    with
        MPTH2FileEditPageAltClickMixin,
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
    if (nextState.type != MPTH2FileEditStateType.selectionWindowZoom) {
      elementEditController.finalizeNewAreaCreation();
    }
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    if (onAltPrimaryButtonClick(event)) {
      return Future.value();
    }

    final ({MPCommand? command, THArea? area}) addLineToAreaRecord =
        await getAddLineToAreaCommand(
          screenCoordinates: event.localPosition,
          th2FileEditController: th2FileEditController,
        );

    if ((addLineToAreaRecord.command == null) ||
        (addLineToAreaRecord.area == null)) {
      return Future.value();
    }

    final THArea area = addLineToAreaRecord.area!;
    final ({String subtype, String type}) typeSubtype =
        MPCommandOptionAux.getPLATypeSubtypeRecord(
          elementEditController.lastUsedAreaType,
        );

    MPCommand? posCommand;

    if (typeSubtype.subtype != '') {
      final THCommandOption toSubtypeOption = THSubtypeCommandOption(
        parentMPID: area.mpID,
        subtype: typeSubtype.subtype,
      );

      posCommand = MPCommandFactory.setOptionOnElements(
        toOption: toSubtypeOption,
        elements: [area],
        thFile: thFile,
      );
    }

    final List<THElement> areaChildren = area.getChildren(thFile).toList();
    final MPCommand addAreaCommand = MPAddAreaCommand.forCWJM(
      newArea: area,
      areaChildren: areaChildren,
      areaPositionInParent: mpAddChildAtEndMinusOneOfParentChildrenList,
      posCommand: posCommand,
    );
    final List<MPCommand> commands = [
      addAreaCommand,
      addLineToAreaRecord.command!,
    ];
    final MPCommand addAreaWithLineCommand =
        MPCommandFactory.multipleCommandsFromList(
          commandsList: commands,
          completionType:
              MPMultipleElementsCommandCompletionType.elementsEdited,
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
