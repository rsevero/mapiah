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
    final List<THElement> elementsInsideSelectionWindow = selectionController
        .selectableElementsInsideWindow(selectionWindow);

    return elementsInsideSelectionWindow;
  }

  List<THElement> getSelectedElementsWithLineSegmentsConvertedToLines(
    Iterable<THElement> selectedWithLineSegments,
  ) {
    final List<THElement> selectedElementsWithLines = [];
    final THFile thFile = th2FileEditController.thFile;

    for (final THElement element in selectedWithLineSegments) {
      if (element is THLineSegment) {
        final THLine line = thFile.lineByMPID(element.parentMPID);
        selectedElementsWithLines.add(line);
      } else {
        selectedElementsWithLines.add(element);
      }
    }

    return selectedElementsWithLines;
  }

  List<int> getSelectedElementsCount() {
    int pointCount = 0;
    int lineCount = 0;
    int areaCount = 0;

    final Iterable<MPSelectedElement> selectedElements =
        selectionController.mpSelectedElementsLogical.values;

    for (final MPSelectedElement selectedElement in selectedElements) {
      switch (selectedElement) {
        case MPSelectedArea _:
          areaCount++;
        case MPSelectedLine _:
          lineCount++;
        case MPSelectedPoint _:
          pointCount++;
      }
    }

    return [pointCount, lineCount, areaCount];
  }
}
