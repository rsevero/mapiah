part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddArea extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin {
  MPTH2FileEditStateAddArea({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(mpLocator.appLocalizations
        .th2FileEditPageAddAreaStatusBarMessage(
            elementEditController.lastUsedAreaType.name));
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    final Map<int, THElement> clickedLines =
        await selectionController.getSelectableElementsClickedWithDialog(
      screenCoordinates: event.localPosition,
      selectionType: THSelectionType.line,
      canBeMultiple: false,
      presentMultipleElementsClickedWidget: true,
    );

    if (clickedLines.isEmpty) {
      return Future.value();
    }

    return Future.value();
    // final THArea newPoint = THPoint(
    //   parentMPID: th2FileEditController.activeScrapID,
    //   pointType: elementEditController.lastUsedPointType,
    //   position: THPositionPart(
    //     coordinates:
    //         th2FileEditController.offsetScreenToCanvas(event.localPosition),
    //     decimalPositions: th2FileEditController.currentDecimalPositions,
    //   ),
    // );
    // final MPAddPointCommand command = MPAddPointCommand(newPoint: newPoint);

    // th2FileEditController.execute(command);
    // th2FileEditController.triggerNonSelectedElementsRedraw();

    // return Future.value();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addArea;
}
