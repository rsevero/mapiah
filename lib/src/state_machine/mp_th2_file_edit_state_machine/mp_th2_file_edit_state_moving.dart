part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateMoving extends MPTH2FileEditState {
  MPTH2FileEditStateMoving({required super.th2FileEditStore});

  /// 1. Moves all selected objects by the distance indicated by [details].
  @override
  void onPanUpdate(DragUpdateDetails details) {
    th2FileEditStore
        .moveSelectedElementsToScreenCoordinates(details.localPosition);
  }

  /// 1. Records an MPCommand that moves the entire selection by the distance
  /// indicated by [details].
  /// 2. Changes to [MPTH2FileEditStateType.selectNonEmptySelection].
  @override
  void onPanEnd(DragEndDetails details) {
    final int selectedCount = th2FileEditStore.selectedElements.length;
    final Offset panDeltaOnCanvas =
        th2FileEditStore.offsetScreenToCanvas(details.localPosition) -
            th2FileEditStore.panStartCanvasCoordinates;

    if (selectedCount == 1) {
      final MPSelectedElement selected =
          th2FileEditStore.selectedElements.values.first;
      final THElement selectedElement = selected.originalElementClone;

      switch (selected) {
        case MPSelectedPoint _:
          final MPMovePointCommand movePointCommand =
              MPMovePointCommand.fromDelta(
            pointMapiahID: selectedElement.mapiahID,
            originalCoordinates:
                (selectedElement as THPoint).position.coordinates,
            deltaOnCanvas: panDeltaOnCanvas,
          );

          th2FileEditStore.execute(movePointCommand);
          break;
        case MPSelectedLine _:
          final MPMoveLineCommand moveLineCommand = MPMoveLineCommand.fromDelta(
            lineMapiahID: selectedElement.mapiahID,
            originalLineSegmentsMap: selected.originalLineSegmentsMapClone,
            deltaOnCanvas: panDeltaOnCanvas,
          );

          th2FileEditStore.execute(moveLineCommand);
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

      final MPMoveElementsCommand moveElementsCommand =
          MPMoveElementsCommand.fromDelta(
        moveCommandOriginalParametersList: moveCommandOriginalParametersList,
        deltaOnCanvas: panDeltaOnCanvas,
      );

      th2FileEditStore.execute(moveElementsCommand);
    }

    th2FileEditStore.setState(MPTH2FileEditStateType.selectNonEmptySelection);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.moving;
}
