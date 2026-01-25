part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddLineToArea extends MPTH2FileEditState
    with
        MPTH2FileEditPageAltClickMixin,
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
    if (onAltPrimaryButtonClick(event)) {
      return Future.value();
    }

    final MPCommand? addLineToAreaCommand = await getAddLineToAreaCommand(
      event: event,
      th2FileEditController: th2FileEditController,
      area: area,
    );

    if (addLineToAreaCommand == null) {
      return Future.value();
    }

    th2FileEditController.execute(addLineToAreaCommand);
    th2FileEditController.triggerAllElementsRedraw();

    return Future.value();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addLineToArea;
}
