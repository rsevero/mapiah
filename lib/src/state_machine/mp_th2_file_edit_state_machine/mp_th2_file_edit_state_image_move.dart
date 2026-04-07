// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateImageMove extends MPTH2FileEditStateImageOperation {
  MPTH2FileEditStateImageMove({
    required super.th2FileEditController,
    required super.imageMPID,
  });

  @override
  void setCursor() {
    th2FileEditController.setCanvasCursor(SystemMouseCursors.grab);
  }

  @override
  String get statusBarMessage =>
      mpLocator.appLocalizations.th2FileEditPageImageMoveStatusBarMessage;

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.imageMove;
}
