part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateGetSelectedElementsMixin on MPTH2FileEditState {
  Set<THElement> getObjectsInsideSelectionWindow(
    Offset screenCoordinatesEndSelectionWindow,
  ) {
    final Offset startSelectionWindow =
        th2FileEditController.dragStartCanvasCoordinates;
    final Offset endSelectionWindow = th2FileEditController
        .offsetScreenToCanvas(screenCoordinatesEndSelectionWindow);
    final Rect selectionWindow = MPNumericAux.orderedRectFromLTRB(
      left: startSelectionWindow.dx,
      top: startSelectionWindow.dy,
      right: endSelectionWindow.dx,
      bottom: endSelectionWindow.dy,
    );
    final Set<THElement> elementsInsideSelectionWindow =
        th2FileEditController.selectableElementsInsideWindow(selectionWindow);

    return elementsInsideSelectionWindow;
  }

  Set<THElement> getSelectedElementsWithLineSegmentsConvertedToLines(
    Set<THElement> selectedWithLineSegments,
  ) {
    final Set<THElement> selectedElementsWithLines = {};
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
