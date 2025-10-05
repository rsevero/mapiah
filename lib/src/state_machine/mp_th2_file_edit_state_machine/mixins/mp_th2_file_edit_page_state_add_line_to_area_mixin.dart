part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditPageStateAddLineToAreaMixin {
  Future<MPCommand?> getAddLineToAreaCommand({
    required PointerUpEvent event,
    required TH2FileEditController th2FileEditController,
    required THArea area,
  }) async {
    final TH2FileEditSelectionController selectionController =
        th2FileEditController.selectionController;
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
    final MPCommand addLineToAreaCommand = MPCommandFactory.addLineToArea(
      area: area,
      line: line,
      thFile: th2FileEditController.thFile,
    );

    return addLineToAreaCommand;
  }
}
