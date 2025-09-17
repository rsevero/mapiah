part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditPageStateAddLineToAreaMixin {
  Future<void> addLineToArea({
    required PointerUpEvent event,
    required TH2FileEditController th2FileEditController,
    required THArea area,
  }) async {
    final TH2FileEditSelectionController selectionController =
        th2FileEditController.selectionController;
    final List<MPCommand> commands = [];
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

    final THLine line = clickedLines.values.first as THLine;

    if (!line.hasOption(THCommandOptionType.id)) {
      if (!area.hasOption(THCommandOptionType.id)) {
        final String newAreaTHID = th2FileEditController.thFile.getNewTHID(
          element: area,
          prefix: mpAreaTHIDPrefix,
        );
        final THIDCommandOption areaTHIDOption = THIDCommandOption(
          optionParent: area,
          thID: newAreaTHID,
        );
        final MPCommand addAreaTHIDCommand = MPSetOptionToElementCommand(
          option: areaTHIDOption,
        );

        commands.add(addAreaTHIDCommand);
      }

      final String areaTHID =
          (area.optionByType(THCommandOptionType.id) as THIDCommandOption).thID;
      final String lineTHIDPrefix = '$areaTHID-$mpLineTHIDPrefix';
      final String newLineTHID = th2FileEditController.thFile.getNewTHID(
        element: line,
        prefix: lineTHIDPrefix,
      );
      final THIDCommandOption lineTHIDOption = THIDCommandOption(
        optionParent: line,
        thID: newLineTHID,
      );
      final MPCommand addLineTHIDCommand = MPSetOptionToElementCommand(
        option: lineTHIDOption,
      );

      commands.add(addLineTHIDCommand);
    }

    final String lineTHID =
        (line.optionByType(THCommandOptionType.id) as THIDCommandOption).thID;
    final THAreaBorderTHID areaBorderTHID = THAreaBorderTHID(
      parentMPID: area.mpID,
      thID: lineTHID,
    );
    final MPCommand addAreaBorderTHIDCommand = MPAddAreaBorderTHIDCommand(
      newAreaBorderTHID: areaBorderTHID,
    );

    commands.add(addAreaBorderTHIDCommand);

    final MPCommand command = (commands.length == 1)
        ? commands.first
        : MPMultipleElementsCommand.forCWJM(
            commandsList: commands,
            completionType:
                MPMultipleElementsCommandCompletionType.optionsEdited,
          );

    th2FileEditController.execute(command);
    th2FileEditController.triggerAllElementsRedraw();

    return Future.value();
  }
}
