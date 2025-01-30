part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMoving extends MPTH2FileEditState {
  MPTH2FileEditStateMoving({required super.th2FileEditStore});

  /// 1. Moves all selected objects by the distance indicated by [event].
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditStore
        .moveSelectedElementsToScreenCoordinates(event.localPosition);
  }

  /// 1. Records an MPCommand that moves the entire selection by the distance
  /// indicated by [event].
  /// 2. Update cloned copies inside TH2FileEditStore.selectedElements.
  /// 3. Trigger redraw of selected elements.
  /// 4. Changes to [MPTH2FileEditStateType.selectNonEmptySelection].
  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final int selectedCount = th2FileEditStore.selectedElements.length;
    final Offset panDeltaOnCanvas =
        th2FileEditStore.primaryButtonDragCanvasDelta;
    late MPCommand moveCommand;

    if (selectedCount == 1) {
      final MPSelectedElement selected =
          th2FileEditStore.selectedElements.values.first;
      final THElement selectedElement = selected.originalElementClone;

      switch (selected) {
        case MPSelectedPoint _:
          moveCommand = MPMovePointCommand.fromDelta(
            pointMapiahID: selectedElement.mapiahID,
            originalCoordinates:
                (selectedElement as THPoint).position.coordinates,
            deltaOnCanvas: panDeltaOnCanvas,
          );
          break;
        case MPSelectedLine _:
          moveCommand = MPMoveLineCommand.fromDelta(
            lineMapiahID: selectedElement.mapiahID,
            originalLineSegmentsMap: selected.originalLineSegmentsMapClone,
            deltaOnCanvas: panDeltaOnCanvas,
          );
          break;
      }
    } else if (selectedCount > 1) {
      final List<MPMoveCommandOriginalParameters>
          moveCommandOriginalParametersList = th2FileEditStore
              .selectedElements.values
              .map<MPMoveCommandOriginalParameters>(
                  (MPSelectedElement selected) {
        final THElement selectedElement = selected.originalElementClone;
        switch (selected) {
          case MPSelectedPoint _:
            return MPMoveCommandPointOriginalParameters(
              mapiahID: selectedElement.mapiahID,
              coordinates: (selectedElement as THPoint).position.coordinates,
            );
          case MPSelectedLine _:
            return MPMoveCommandLineOriginalParameters(
              mapiahID: selectedElement.mapiahID,
              lineSegmentsMap: selected.originalLineSegmentsMapClone,
            );
          default:
            throw UnimplementedError();
        }
      }).toList();

      moveCommand = MPMoveElementsCommand.fromDelta(
        moveCommandOriginalParametersList: moveCommandOriginalParametersList,
        deltaOnCanvas: panDeltaOnCanvas,
      );
    }
    th2FileEditStore.execute(moveCommand);

    th2FileEditStore.updateSelectedElementsClones();

    th2FileEditStore.triggerSelectedElementsRedraw();

    th2FileEditStore.setState(MPTH2FileEditStateType.selectNonEmptySelection);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.moving;
}
