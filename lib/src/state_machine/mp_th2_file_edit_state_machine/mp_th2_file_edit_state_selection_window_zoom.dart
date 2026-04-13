// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateSelectionWindowZoom extends MPTH2FileEditState
    with
        MPTH2FileEditPageAltClickMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin,
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateKeyDownMixin,
        MPTH2FileEditStateOptionsEditMixin {
  MPTH2FileEditStateSelectionWindowZoom({required super.th2FileEditController});

  late final MPTH2FileEditStateType _previousStateType;
  Offset? _dragStartScreenCoordinates;

  @override
  void setCursor() {
    th2FileEditController.setCanvasCursor(SystemMouseCursors.precise);
  }

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    _previousStateType = previousState.type;
    updateStatusBarMessage();
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
  void updateStatusBarMessage() {
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
    if (!_isSelectionWindowLargeEnoughOnScreen(event.localPosition)) {
      _leaveState();

      return;
    }

    final Rect selectionWindowRect = selectionController
        .getSelectionWindowCanvasRect();

    th2FileEditController.zoomToSelectionWindow(selectionWindowRect);
    _leaveState();
  }

  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) {
    _leaveState();

    return Future.value();
  }

  /// Marks the start point of the selection window.
  @override
  void onPrimaryButtonPointerDown(PointerDownEvent event) {
    _dragStartScreenCoordinates = event.localPosition;
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

  bool _isSelectionWindowLargeEnoughOnScreen(Offset dragEndScreenCoordinates) {
    final Offset? dragStartScreenCoordinates = _dragStartScreenCoordinates;

    if (dragStartScreenCoordinates == null) {
      return false;
    }

    final double minimumWindowSizeOnScreen = mpLocator.mpSettingsController
        .getDoubleWithDefault(MPSettingID.TH2Edit_SelectionTolerance);
    final double dx =
        (dragEndScreenCoordinates.dx - dragStartScreenCoordinates.dx).abs();
    final double dy =
        (dragEndScreenCoordinates.dy - dragStartScreenCoordinates.dy).abs();

    return (dx >= minimumWindowSizeOnScreen) &&
        (dy >= minimumWindowSizeOnScreen);
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.selectionWindowZoom;
}
