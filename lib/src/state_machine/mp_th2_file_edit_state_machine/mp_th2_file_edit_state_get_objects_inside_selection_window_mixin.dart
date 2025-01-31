part of 'mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateGetObjectsInsideSelectionWindowMixin
    on MPTH2FileEditState {
  List<THElement> _getObjectsInsideSelectionWindow(
    Offset screenCoordinatesEndSelectionWindow,
  ) {
    final Offset startSelectionWindow =
        th2FileEditStore.panStartCanvasCoordinates;
    final Offset endSelectionWindow = th2FileEditStore
        .offsetScreenToCanvas(screenCoordinatesEndSelectionWindow);
    final Rect selectionWindow = MPNumericAux.orderedRectFromLTRB(
      left: startSelectionWindow.dx,
      top: startSelectionWindow.dy,
      right: endSelectionWindow.dx,
      bottom: endSelectionWindow.dy,
    );
    final List<THElement> elementsInsideSelectionWindow =
        th2FileEditStore.selectableElementsInsideWindow(selectionWindow);

    return elementsInsideSelectionWindow;
  }
}
