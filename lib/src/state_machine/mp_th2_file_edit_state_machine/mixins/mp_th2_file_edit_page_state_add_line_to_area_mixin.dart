part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditPageStateAddLineToAreaMixin {
  Future<({MPCommand? command, THArea? area})> getAddLineToAreaCommand({
    required Offset screenCoordinates,
    required TH2FileEditController th2FileEditController,
    THArea? area,
  }) async {
    final TH2FileEditSelectionController selectionController =
        th2FileEditController.selectionController;
    final Map<int, THElement> clickedLines = await selectionController
        .getSelectableElementsClickedWithDialog(
          screenCoordinates: screenCoordinates,
          selectionType: THSelectionType.line,
          canBeMultiple: false,
          presentMultipleElementsClickedWidget: true,
        );

    if (clickedLines.isEmpty) {
      return Future.value((command: null, area: null));
    }

    area ??= th2FileEditController.elementEditController.getNewArea();

    final THLine line = clickedLines.values.first as THLine;
    final MPCommand addLineToAreaCommand = MPCommandFactory.addLineToArea(
      area: area,
      line: line,
      thFile: th2FileEditController.thFile,
    );

    return Future.value((command: addLineToAreaCommand, area: area));
  }
}
