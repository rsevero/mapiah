part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddPoint extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddPoint({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(mpLocator.appLocalizations
        .th2FileEditPageAddPointStatusBarMessage(
            elementEditController.lastAddedPointType.name));
  }

  @override
  void onPrimaryButtonClick(PointerUpEvent event) {
    final THPoint newPoint = THPoint(
      parentMapiahID: th2FileEditController.activeScrapID,
      pointType: elementEditController.lastAddedPointType,
      position: THPositionPart(
        coordinates:
            th2FileEditController.offsetScreenToCanvas(event.localPosition),
        decimalPositions: th2FileEditController.currentDecimalPositions,
      ),
    );
    final MPAddPointCommand command = MPAddPointCommand(newPoint: newPoint);

    th2FileEditController.execute(command);
    th2FileEditController.triggerNonSelectedElementsRedraw();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addPoint;
}
