part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddPoint extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddPoint({required super.fileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    fileEditController.setStatusBarMessage(mpLocator.appLocalizations
        .th2FileEditPageAddPointStatusBarMessage(
            addElementController.lastAddedPointType.name));
  }

  @override
  void onPrimaryButtonClick(PointerUpEvent event) {
    final THPoint newPoint = THPoint(
      parentMapiahID: fileEditController.activeScrapID,
      pointType: addElementController.lastAddedPointType,
      position: THPositionPart(
        coordinates:
            fileEditController.offsetScreenToCanvas(event.localPosition),
        decimalPositions: fileEditController.currentDecimalPositions,
      ),
    );
    final MPAddPointCommand command = MPAddPointCommand(newPoint: newPoint);

    fileEditController.execute(command);
    fileEditController.triggerNonSelectedElementsRedraw();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addPoint;
}
