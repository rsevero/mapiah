// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateImageRotate extends MPTH2FileEditStateImageOperation {
  MPTH2FileEditStateImageRotate({
    required super.th2FileEditController,
    required super.imageMPID,
  });

  @override
  String get overlayLabel =>
      mpLocator.appLocalizations.th2FileEditPageImageRotateOverlayLabel;

  @override
  String get statusBarMessage =>
      mpLocator.appLocalizations.th2FileEditPageImageRotateStatusBarMessage;

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.imageRotate;
}
