// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddArea extends MPTH2FileEditState
    with
        MPTH2FileEditPageAltClickMixin,
        MPTH2FileEditPageStateAddLineToAreaMixin,
        MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddArea({required super.th2FileEditController});

  @override
  void setCursor() {
    th2FileEditController.setCanvasCursor(SystemMouseCursors.basic);
  }

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
      th2FileEditController.areaLineCreationController
          .finalizeNewAreaCreation();
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

    final List<MPCommand> posCommands = [];

    if (typeSubtype.subtype != '') {
      final THCommandOption toSubtypeOption = THSubtypeCommandOption(
        parentMPID: area.mpID,
        subtype: typeSubtype.subtype,
      );

      posCommands.add(
        MPCommandFactory.setOptionOnElements(
          toOption: toSubtypeOption,
          elements: [area],
          th2File: th2File,
        ),
      );
    }

    final List<THCommandOption> defaultOptions = th2FileEditController
        .defaultOptionsController
        .getApplicableDefaults(
          elementType: THElementType.area,
          typeString: typeSubtype.type,
        );

    for (final THCommandOption defaultOption in defaultOptions) {
      if (defaultOption.type == THCommandOptionType.subtype) {
        continue;
      }
      posCommands.add(
        MPCommandFactory.setOptionOnElements(
          toOption: defaultOption.copyWith(
            parentMPID: area.mpID,
            originalLineInTH2File: '',
          ),
          elements: [area],
          th2File: th2File,
        ),
      );
    }

    final MPCommand? posCommand = posCommands.isEmpty
        ? null
        : MPCommandFactory.multipleCommandsFromList(
            commandsList: posCommands,
            descriptionType: MPCommandDescriptionType.addArea,
            completionType:
                MPMultipleElementsCommandCompletionType.elementsListChanged,
          );

    final List<THElement> areaChildren = area.getChildren(th2File).toList();
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
            th2FileEditController.areaLineCreationController.getNewArea(),
          ], setState: true);

          return;
        }
    }

    _onKeyDownEvent(event);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addArea;
}
