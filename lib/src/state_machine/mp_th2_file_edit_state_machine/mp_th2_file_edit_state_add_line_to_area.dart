part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddLineToArea extends MPTH2FileEditState
    with
        MPTH2FileEditPageStateAddLineToAreaMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateMoveCanvasMixin {
  late final THArea area;

  MPTH2FileEditStateAddLineToArea({required super.th2FileEditController}) {
    final Iterable<MPSelectedElement> mpSelectedElements = th2FileEditController
        .selectionController
        .mpSelectedElementsLogical
        .values;

    if ((mpSelectedElements.length != 1) ||
        (mpSelectedElements.first.originalElementClone.elementType !=
            THElementType.area)) {
      throw StateError(
        'prepareAddAreaBorderTHID can only be called when a single area is selected.',
      );
    }

    area = mpSelectedElements.first.originalElementClone as THArea;
  }

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations.th2FileEditPageAddLineToAreaStatusBarMessage(
        MPTextToUser.getAreaType(area.areaType),
      ),
    );
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    onStateExitClearSelectionOnExit(nextState);
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) async {
    return addLineToArea(
      event: event,
      th2FileEditController: th2FileEditController,
      area: area,
    );
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addLineToArea;
}
