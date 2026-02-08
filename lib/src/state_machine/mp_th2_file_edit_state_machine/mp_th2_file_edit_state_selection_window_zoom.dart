part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSelectionWindowZoom extends MPTH2FileEditState
    with
        MPTH2FileEditPageAltClickMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateOptionsEditMixin {
  MPTH2FileEditStateSelectionWindowZoom({required super.th2FileEditController});

  late final MPTH2FileEditStateType _previousStateType;

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    _previousStateType = previousState.type;
    setStatusBarMessage();
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    th2FileEditController.selectionController.clearSelectionWindow();
    th2FileEditController.setStatusBarMessage('');
  }

  void _leaveState() {
    th2FileEditController.stateController.setState(_previousStateType);
  }

  @override
  void setStatusBarMessage() {
    th2FileEditController.setStatusBarMessage(
      mpLocator
          .appLocalizations
          .th2FileEditPageSelectionWindowZoomStatusBarMessage,
    );
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    _leaveState();
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final Rect selectionWindowRect = selectionController
        .getSelectionWindowCanvasRect();

    th2FileEditController.zoomToSelectionWindow(selectionWindowRect);
    _leaveState();
  }

  /// Marks the start point of the selection window.
  @override
  void onPrimaryButtonPointerDown(PointerDownEvent event) {
    selectionController.setDragStartCoordinatesFromScreenCoordinates(
      event.localPosition,
    );
  }

  /// Draws the selection window.
  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    selectionController.setSelectionWindowScreenEndCoordinates(
      event.localPosition,
    );
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.selectionWindowZoom;
}
