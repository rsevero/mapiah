part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditPageStateAddLineToAreaMixin {
  Future<void> addLineToArea({
    required PointerUpEvent event,
    required TH2FileEditController th2FileEditController,
    required THArea area,
  }) async {
    final TH2FileEditSelectionController selectionController =
        th2FileEditController.selectionController;
    final TH2FileEditElementEditController elementEditController =
        th2FileEditController.elementEditController;

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
        elementEditController.addAutomaticTHIDOption(
          element: area,
          prefix: mpAreaTHIDPrefix,
        );
      }

      final String areaTHID =
          (area.optionByType(THCommandOptionType.id) as THIDCommandOption).thID;
      final String lineTHIDPrefix = '$areaTHID-$mpLineTHIDPrefix';

      elementEditController.addAutomaticTHIDOption(
        element: line,
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
    th2FileEditController.triggerAllElementsRedraw();

    return Future.value();
  }
}
