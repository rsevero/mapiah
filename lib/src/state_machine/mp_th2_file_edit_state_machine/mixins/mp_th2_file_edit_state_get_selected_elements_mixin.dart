part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateGetSelectedElementsMixin on MPTH2FileEditState {
  List<THElement> getObjectsInsideSelectionWindow(
    Offset screenCoordinatesEndSelectionWindow,
  ) {
    final Offset startSelectionWindow =
        selectionController.dragStartCanvasCoordinates;
    final Offset endSelectionWindow = th2FileEditController
        .offsetScreenToCanvas(screenCoordinatesEndSelectionWindow);
    final Rect selectionWindow = MPNumericAux.orderedRectFromLTRB(
      left: startSelectionWindow.dx,
      top: startSelectionWindow.dy,
      right: endSelectionWindow.dx,
      bottom: endSelectionWindow.dy,
    );
    final List<THElement> elementsInsideSelectionWindow =
        selectionController.selectableElementsInsideWindow(selectionWindow);

    return elementsInsideSelectionWindow;
  }

  List<THElement> getSelectedElementsWithLineSegmentsConvertedToLines(
    List<THElement> selectedWithLineSegments,
  ) {
    final List<THElement> selectedElementsWithLines = [];
    final THFile thFile = th2FileEditController.thFile;

    for (final THElement element in selectedWithLineSegments) {
      if (element is THLineSegment) {
        final THLine line =
            thFile.elementByMapiahID(element.parentMapiahID) as THLine;
        selectedElementsWithLines.add(line);
      } else {
        selectedElementsWithLines.add(element);
      }
    }

    return selectedElementsWithLines;
  }
}
