// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditStateResetAreaBorderCtrlMetaCycleMixin
    on MPTH2FileEditState {
  @override
  void onKeyUpEvent(KeyUpEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.altLeft:
      case LogicalKeyboardKey.altRight:
      case LogicalKeyboardKey.altGraph:
      case LogicalKeyboardKey.controlLeft:
      case LogicalKeyboardKey.controlRight:
      case LogicalKeyboardKey.metaLeft:
      case LogicalKeyboardKey.metaRight:
      case LogicalKeyboardKey.shiftLeft:
      case LogicalKeyboardKey.shiftRight:
        selectionController.resetAreaBorderCtrlMetaCycle();
      default:
    }

    super.onKeyUpEvent(event);
  }
}
