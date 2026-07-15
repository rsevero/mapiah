// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateAddFreehandLine extends MPTH2FileEditState
    with MPTH2FileEditStateMoveCanvasMixin, MPTH2FileEditStateKeyDownMixin {
  MPTH2FileEditStateAddFreehandLine({required super.th2FileEditController});

  @override
  void setCursor() {
    th2FileEditController.setCanvasCursor(SystemMouseCursors.precise);
  }

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    final MPPLATypeSubtype lineTypeSubtype = elementEditController
        .getLineTypeAndSubtypeForNewLine();

    th2FileEditController.setStatusBarMessage(
      mpLocator.appLocalizations
          .th2FileEditPageAddFreehandLineStatusBarMessage(
            lineTypeSubtype.typeSubtypeID,
          ),
    );
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    th2FileEditController.freehandLineCreationController.abandonStroke();
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  void onPrimaryButtonPointerDown(PointerDownEvent event) {
    th2FileEditController.freehandLineCreationController.startStroke(
      event.localPosition,
    );
    th2FileEditController.setCanvasCursor(SystemMouseCursors.grabbing);
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditController.freehandLineCreationController.appendStrokeSample(
      event.localPosition,
    );
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    th2FileEditController.freehandLineCreationController.finishStroke(
      event.localPosition,
    );
    setCursor();
  }

  /// [MPListenerWidget] reports a pointer-up that never crossed the drag
  /// threshold as a click rather than a drag end, so the one-point stroke
  /// started on pointer-down must be abandoned here instead of committed.
  @override
  Future<void> onPrimaryButtonClick(PointerUpEvent event) {
    th2FileEditController.freehandLineCreationController.abandonStroke();
    setCursor();

    return Future.value();
  }

  @override
  void onPrimaryButtonPointerCancel(PointerCancelEvent event) {
    th2FileEditController.freehandLineCreationController.abandonStroke();
    setCursor();
  }

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (!MPInteractionAux.isAltPressed() &&
          !MPInteractionAux.isCtrlPressed() &&
          !MPInteractionAux.isMetaPressed() &&
          !MPInteractionAux.isShiftPressed() &&
          th2FileEditController.freehandLineCreationController.isCapturing) {
        th2FileEditController.freehandLineCreationController.abandonStroke();
        setCursor();

        return;
      }
    }

    _onKeyDownEvent(event);
  }

  @override
  void onSelectAll() {
    selectionController.selectAllElements();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.addFreehandLine;
}
